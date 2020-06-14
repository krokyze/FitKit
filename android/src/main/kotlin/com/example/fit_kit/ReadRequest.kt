package com.example.fit_kit

import io.flutter.plugin.common.MethodCall
import java.util.*

abstract class ReadRequest<T : Type> private constructor(
        val type: T,
        val dateFrom: Date,
        val dateTo: Date,
        val limit: Int?
) {

    class Sample(type: Type.Sample, dateFrom: Date, dateTo: Date, limit: Int?)
        : ReadRequest<Type.Sample>(type, dateFrom, dateTo, limit)

    class Activity(type: Type.Activity, dateFrom: Date, dateTo: Date, limit: Int?)
        : ReadRequest<Type.Activity>(type, dateFrom, dateTo, limit)

    companion object {
        @Throws
        fun fromCall(call: MethodCall): ReadRequest<*> {
            val type = call.argument<String>("type")?.let {
                it.fromDartType() ?: throw UnsupportedException("type $it is not supported")
            } ?: throw Exception("type is not defined")
            val dateFrom = safeLong(call, "date_from")?.let { Date(it) }
                    ?: throw Exception("date_from is not defined")
            val dateTo = safeLong(call, "date_to")?.let { Date(it) }
                    ?: throw Exception("date_to is not defined")
            val limit = call.argument<Int?>("limit")

            return when (type) {
                is Type.Sample -> Sample(type, dateFrom, dateTo, limit)
                is Type.Activity -> Activity(type, dateFrom, dateTo, limit)
            }
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