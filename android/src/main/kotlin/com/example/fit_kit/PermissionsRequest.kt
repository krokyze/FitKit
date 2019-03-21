package com.example.fit_kit

import com.google.android.gms.fitness.data.DataType
import io.flutter.plugin.common.MethodCall

class PermissionsRequest private constructor(
        val types: List<String>,
        val dataTypes: List<DataType>
) {

    companion object {
        @Throws
        fun fromCall(call: MethodCall): PermissionsRequest {
            val types = call.argument<List<String>>("types")
                    ?: throw Exception("types is not defined")
            val dataTypes = types.map { type -> type.fromDartType() }

            return PermissionsRequest(types, dataTypes)
        }
    }
}