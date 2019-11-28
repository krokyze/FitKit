package com.example.fit_kit

import com.google.android.gms.fitness.data.DataType

sealed class Type(val dataType: DataType) {
    class Sample(dataType: DataType) : Type(dataType)
    class Activity(val activity: String) : Type(DataType.TYPE_ACTIVITY_SEGMENT)
}
