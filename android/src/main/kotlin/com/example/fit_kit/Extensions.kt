package com.example.fit_kit

import com.google.android.gms.fitness.data.DataType

@Throws
fun String.fromDartType(): DataType {
    return when (this) {
        "heart_rate" -> DataType.TYPE_HEART_RATE_BPM
        "step_count" -> DataType.TYPE_STEP_COUNT_DELTA
        "height" -> DataType.TYPE_HEIGHT
        "weight" -> DataType.TYPE_WEIGHT
        "distance" -> DataType.TYPE_DISTANCE_DELTA
        "energy" -> DataType.TYPE_CALORIES_EXPENDED
        "water" -> DataType.TYPE_HYDRATION
        else -> throw Exception("type $this is not supported")
    }
}