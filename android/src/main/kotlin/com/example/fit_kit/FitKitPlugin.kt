package com.example.fit_kit

import android.app.Activity
import android.util.Log
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataPoint
import com.google.android.gms.fitness.data.DataSet
import com.google.android.gms.fitness.data.Field
import com.google.android.gms.fitness.data.Session
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.fitness.request.SessionReadRequest
import com.google.android.gms.fitness.result.DataReadResponse
import com.google.android.gms.fitness.result.SessionReadResponse
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.TimeUnit


class FitKitPlugin(private val registrar: Registrar) : MethodCallHandler {

    interface OAuthPermissionsListener {
        fun onOAuthPermissionsResult(resultCode: Int)
    }

    private val oAuthPermissionListeners = mutableListOf<OAuthPermissionsListener>()

    init {
        registrar.addActivityResultListener { requestCode, resultCode, _ ->
            if (requestCode == GOOGLE_FIT_REQUEST_CODE) {
                oAuthPermissionListeners.toList()
                        .forEach { it.onOAuthPermissionsResult(resultCode) }
                return@addActivityResultListener true
            }
            return@addActivityResultListener false
        }
    }

    companion object {
        private const val TAG = "FitKit"
        private const val TAG_UNSUPPORTED = "unsupported"
        private const val GOOGLE_FIT_REQUEST_CODE = 8008

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "fit_kit")
            channel.setMethodCallHandler(FitKitPlugin(registrar))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "hasPermissions" -> {
                    val request = PermissionsRequest.fromCall(call)
                    hasPermissions(request, result)
                }
                "requestPermissions" -> {
                    val request = PermissionsRequest.fromCall(call)
                    requestPermissions(request, result)
                }
                "revokePermissions" -> revokePermissions(result)
                "read" -> {
                    val request = ReadRequest.fromCall(call)
                    read(request, result)
                }
                else -> result.notImplemented()
            }
        } catch (e: UnsupportedException) {
            result.error(TAG_UNSUPPORTED, e.message, null)
        } catch (e: Throwable) {
            result.error(TAG, e.message, null)
        }
    }

    private fun hasPermissions(request: PermissionsRequest, result: Result) {
        val options = FitnessOptions.builder()
                .addDataTypes(request.types.map { it.dataType })
                .build()

        if (hasOAuthPermission(options)) {
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun requestPermissions(request: PermissionsRequest, result: Result) {
        val options = FitnessOptions.builder()
                .addDataTypes(request.types.map { it.dataType })
                .build()

        requestOAuthPermissions(options, {
            result.success(true)
        }, {
            result.success(false)
        })
    }

    /**
     * let's wait for some answers
     * https://github.com/android/fit-samples/issues/28#issuecomment-557865949
     */
    private fun revokePermissions(result: Result) {
        val fitnessOptions = FitnessOptions.builder()
                .build()

        if (!hasOAuthPermission(fitnessOptions)) {
            result.success(null)
            return
        }

        Fitness.getConfigClient(registrar.context(), GoogleSignIn.getLastSignedInAccount(registrar.context())!!)
                .disableFit()
                .continueWithTask {
                    val signInOptions = GoogleSignInOptions.Builder()
                            .addExtension(fitnessOptions)
                            .build()
                    GoogleSignIn.getClient(registrar.context(), signInOptions)
                            .revokeAccess()
                }
                .addOnSuccessListener { result.success(null) }
                .addOnFailureListener { e ->
                    if (!hasOAuthPermission(fitnessOptions)) {
                        result.success(null)
                    } else {
                        result.error(TAG, e.message, null)
                    }
                }
    }

    private fun read(request: ReadRequest<*>, result: Result) {
        val options = FitnessOptions.builder()
                .addDataType(request.type.dataType)
                .build()

        requestOAuthPermissions(options, {
            when (request) {
                is ReadRequest.Sample -> readSample(request, result)
                is ReadRequest.Activity -> readSession(request, result)
            }
        }, {
            result.error(TAG, "User denied permission access", null)
        })
    }

    private fun requestOAuthPermissions(fitnessOptions: FitnessOptions, onSuccess: () -> Unit, onError: () -> Unit) {
        if (hasOAuthPermission(fitnessOptions)) {
            onSuccess()
            return
        }

        oAuthPermissionListeners.add(object : OAuthPermissionsListener {
            override fun onOAuthPermissionsResult(resultCode: Int) {
                oAuthPermissionListeners.remove(this)

                if (resultCode == Activity.RESULT_OK) {
                    onSuccess()
                } else {
                    onError()
                }
            }
        })

        GoogleSignIn.requestPermissions(
                registrar.activity(),
                GOOGLE_FIT_REQUEST_CODE,
                GoogleSignIn.getLastSignedInAccount(registrar.context()),
                fitnessOptions)
    }

    private fun hasOAuthPermission(fitnessOptions: FitnessOptions): Boolean {
        return GoogleSignIn.hasPermissions(GoogleSignIn.getLastSignedInAccount(registrar.context()), fitnessOptions)
    }

    private fun readSample(request: ReadRequest<Type.Sample>, result: Result) {
        Log.d(TAG, "readSample: ${request.type}")

        val readRequest = DataReadRequest.Builder()
                .read(request.type.dataType)
                .also { builder ->
                    when (request.limit != null) {
                        true -> builder.setLimit(request.limit)
                        else -> builder.bucketByTime(1, TimeUnit.DAYS)
                    }
                }
                .setTimeRange(request.dateFrom.time, request.dateTo.time, TimeUnit.MILLISECONDS)
                .enableServerQueries()
                .build()

        Fitness.getHistoryClient(registrar.context(), GoogleSignIn.getLastSignedInAccount(registrar.context())!!)
                .readData(readRequest)
                .addOnSuccessListener { response -> onSuccess(response, result) }
                .addOnFailureListener { e -> result.error(TAG, e.message, null) }
                .addOnCanceledListener { result.error(TAG, "GoogleFit Cancelled", null) }
    }

    private fun onSuccess(response: DataReadResponse, result: Result) {
        (response.dataSets + response.buckets.flatMap { it.dataSets })
                .filterNot { it.isEmpty }
                .flatMap { it.dataPoints }
                .map(::dataPointToMap)
                .let(result::success)
    }

    @Suppress("IMPLICIT_CAST_TO_ANY")
    private fun dataPointToMap(dataPoint: DataPoint): Map<String, Any> {
        val field = dataPoint.dataType.fields.first()
        val source = dataPoint.originalDataSource.streamName

        return mapOf(
                "value" to dataPoint.getValue(field).let { value ->
                    when (value.format) {
                        Field.FORMAT_FLOAT -> value.asFloat()
                        Field.FORMAT_INT32 -> value.asInt()
                        else -> TODO("for future fields")
                    }
                },
                "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                "source" to source,
                "user_entered" to (source == "user_input")
        )
    }

    private fun readSession(request: ReadRequest<Type.Activity>, result: Result) {
        Log.d(TAG, "readSession: ${request.type.activity}")

        val readRequest = SessionReadRequest.Builder()
                .read(request.type.dataType)
                .setTimeInterval(request.dateFrom.time, request.dateTo.time, TimeUnit.MILLISECONDS)
                .readSessionsFromAllApps()
                .enableServerQueries()
                .build()

        Fitness.getSessionsClient(registrar.context(), GoogleSignIn.getLastSignedInAccount(registrar.context())!!)
                .readSession(readRequest)
                .addOnSuccessListener { response -> onSuccess(request, response, result) }
                .addOnFailureListener { e -> result.error(TAG, e.message, null) }
                .addOnCanceledListener { result.error(TAG, "GoogleFit Cancelled", null) }
    }

    private fun onSuccess(request: ReadRequest<Type.Activity>, response: SessionReadResponse, result: Result) {
        response.sessions.filter { request.type.activity == it.activity }
                .let { list ->
                    when (request.limit != null) {
                        true -> list.takeLast(request.limit)
                        else -> list
                    }
                }
                .map { session -> sessionToMap(session, response.getDataSet(session)) }
                .let(result::success)
    }

    private fun sessionToMap(session: Session, dataSets: List<DataSet>): Map<String, Any> {
        // from all data points find the top used streamName
        val source = dataSets.asSequence()
                .filterNot { it.isEmpty }
                .flatMap { it.dataPoints.asSequence() }
                .filterNot { it.originalDataSource.streamName.isNullOrEmpty() }
                .groupingBy { it.originalDataSource.streamName }
                .eachCount()
                .maxBy { it.value }
                ?.key ?: session.name ?: ""

        return mapOf(
                "value" to session.getValue(),
                "date_from" to session.getStartTime(TimeUnit.MILLISECONDS),
                "date_to" to session.getEndTime(TimeUnit.MILLISECONDS),
                "source" to source,
                "user_entered" to (source == "user_input")
        )
    }
}
