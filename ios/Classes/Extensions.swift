//
// Created by Martin Anderson on 2019-03-10.
//

import HealthKit

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

extension HKSampleType {
    public static func fromDartType(type: String) -> (sampleType: HKSampleType?, unit: HKUnit)? {
        switch type {
        case "heart_rate":
            return (
                    HKSampleType.quantityType(forIdentifier: .heartRate),
                    HKUnit.init(from: "count/min")
            )
        case "step_count":
            return (
                    HKSampleType.quantityType(forIdentifier: .stepCount),
                    HKUnit.count()
            )
        case "stand_time":
            if #available(iOS 13.0, *) {
                return (
                        HKSampleType.quantityType(forIdentifier: .appleStandTime),
                        HKUnit.minute()
                )
            } else {
                return nil
            }
        case "exercise_time":
            if #available(iOS 9.3, *) {
                return (
                        HKSampleType.quantityType(forIdentifier: .appleExerciseTime),
                        HKUnit.minute()
                )
            } else {
                return nil
            }
        case "height":
            return (
                    HKSampleType.quantityType(forIdentifier: .height),
                    HKUnit.meter()
            )
        case "weight":
            return (
                    HKSampleType.quantityType(forIdentifier: .bodyMass),
                    HKUnit.gramUnit(with: .kilo)
            )
        case "distance":
            return (
                    HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
                    HKUnit.meter()
            )
        case "energy":
            return (
                    HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
                    HKUnit.kilocalorie()
            )
        case "water":
            if #available(iOS 9, *) {
                return (
                        HKSampleType.quantityType(forIdentifier: .dietaryWater),
                        HKUnit.liter()
                )
            } else {
                return nil
            }
        case "sleep":
            return (
                    HKSampleType.categoryType(forIdentifier: .sleepAnalysis),
                    HKUnit.minute() // this is ignored
            )
        default:
            return nil
        }
    }
}

public struct UnsupportedError: Error {
    let message: String
}