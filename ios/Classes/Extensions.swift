//
// Created by Martin Anderson on 2019-03-10.
//

import HealthKit

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

extension HKQuantityType {
    public static func fromDartType(type: String) throws -> HKQuantityType {
        guard let quantityType: HKQuantityType = {
            switch type {
            case "heart_rate":
                return HKQuantityType.quantityType(forIdentifier: .heartRate)
            case "step_count":
                return HKQuantityType.quantityType(forIdentifier: .stepCount)
            case "stand_time":
                if #available(iOS 13.0, *) {
                     return HKQuantityType.quantityType(forIdentifier: .appleStandTime)
                } else {
                    return nil
                } 
            case "exercise_time":
                if #available(iOS 9.3, *) {
                     return HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)
                } else {
                    return nil
                }  
            case "height":
                return HKQuantityType.quantityType(forIdentifier: .height)
            case "weight":
                return HKQuantityType.quantityType(forIdentifier: .bodyMass)
            case "distance":
                return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
            case "energy":
                return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
            case "water":
                if #available(iOS 9, *) {
                    return HKQuantityType.quantityType(forIdentifier: .dietaryWater)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported";
        }
        return quantityType
    }
}

extension HKUnit {
    public static func fromDartType(type: String) throws -> HKUnit {
        guard let unit: HKUnit = {
            switch (type) {
            case "heart_rate":
                return HKUnit.init(from: "count/min")
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