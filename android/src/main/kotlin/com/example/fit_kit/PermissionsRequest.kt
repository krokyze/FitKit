package com.example.fit_kit

import io.flutter.plugin.common.MethodCall

class PermissionsRequest private constructor(val types: List<Type>) {

    companion object {
        @Throws
        fun fromCall(call: MethodCall): PermissionsRequest {
            val types = call.argument<List<String>>("types")
                    ?.mapNotNull { type -> type.fromDartType() }
                    ?: throw Exception("types is not defined")

            return PermissionsRequest(types)
        }
    }
}