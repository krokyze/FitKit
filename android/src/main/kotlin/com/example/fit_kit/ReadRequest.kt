package com.example.fit_kit

import com.google.android.gms.fitness.data.DataType
import io.flutter.plugin.common.MethodCall
import java.util.*

class ReadRequest private constructor(
        val type: String,
        val dataType: DataType,
        val dateFrom: Date,
        val dateTo: Date
) {

    companion object {
        @Throws
        fun fromCall(call: MethodCall): ReadRequest {
            val type = call.argument<String>("type") ?: throw Exception("type is not defined")
            val dataType = type.fromDartType()

            val dateFrom = safeLong(call, "date_from")?.let { Date(it) }
                    ?: throw Exception("date_from is not defined")
            val dateTo = safeLong(call, "date_to")?.let { Date(it) }
                    ?: throw Exception("date_to is not defined")


            return ReadRequest(type, dataType, dateFrom, dateTo)
        }

        /**
         *  Dart | Android
         *  int	   java.lang.Integer
         *  int    java.lang.Long
         */
        private fun safeLong(call: MethodCall, key: String): Long? {
            val value: Any? = call.argument(key)
            return when (value) {
                is Int -> value.toLong()
                is Long -> value
                else -> null
            }
        }
    }
}