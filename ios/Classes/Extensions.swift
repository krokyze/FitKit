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
    public static func fromDartType(type: String) throws -> HKSampleType {
        guard let sampleType: HKSampleType = {
            switch type {
            case "heart_rate":
                return HKSampleType.quantityType(forIdentifier: .heartRate)
             case "resting_heart_rate":
                if #available(iOS 11.0, *) {
                 return HKSampleType.quantityType(forIdentifier: .restingHeartRate)
                } else {
                 return nil
                }
            case "irregular_heart_rhythm_event":
                if #available(iOS 12.2, *) {
                    return HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)
                } else {
                    return nil
                }
            case "high_heart_rate_event":
                if #available(iOS 12.2, *) {
                    return HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)
                } else {
                    return nil
            }
            case "low_heart_rate_event":
                if #available(iOS 12.2, *) {
                    return HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)
                } else {
                    return nil
            }
            case "step_count":
                return HKSampleType.quantityType(forIdentifier: .stepCount)
            case "stand_time":
                if #available(iOS 13.0, *) {
                     return HKSampleType.quantityType(forIdentifier: .appleStandTime)
                } else {
                    return nil
                } 
            case "exercise_time":
                if #available(iOS 9.3, *) {
                     return HKSampleType.quantityType(forIdentifier: .appleExerciseTime)
                } else {
                    return nil
                }  
            case "height":
                return HKSampleType.quantityType(forIdentifier: .height)
            case "weight":
                return HKSampleType.quantityType(forIdentifier: .bodyMass)
            case "distance":
                return HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
            case "energy":
                return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
            case "water":
                if #available(iOS 9, *) {
                    return HKSampleType.quantityType(forIdentifier: .dietaryWater)
                } else {
                    return nil
                }
            case "sleep":
                return HKSampleType.categoryType(forIdentifier: .sleepAnalysis)
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported";
        }
        return sampleType
    }
}

extension HKUnit {
    public static func fromDartType(type: String) throws -> HKUnit {
        guard let unit: HKUnit = {
            switch (type) {
            case "heart_rate":
                return HKUnit.init(from: "count/min")
            case "resting_heart_rate":
                return HKUnit.init(from: "count/min")
            case "irregular_heart_rhythm_event":
                return HKUnit.count() //Ignored
            case "high_heart_rate_event":
                return HKUnit.count() //Ignored
            case "low_heart_rate_event":
                return HKUnit.count() //Ignored
            case "step_count":
                return HKUnit.count()
            case "height":
                return HKUnit.meter()
            case "weight":
                return HKUnit.gramUnit(with: .kilo)
            case "distance":
                return HKUnit.meter()
            case "energy":
                return HKUnit.kilocalorie()
            case "water":
                return HKUnit.liter()
            case "sleep":
                return HKUnit.minute() // this is ignored
            case "stand_time":
                return HKUnit.minute()
            case "exercise_time":
                return HKUnit.minute()
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported";
        }
        return unit
    }
}
