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
            case "step_count":
                return HKSampleType.quantityType(forIdentifier: .stepCount)
            case "height":
                return HKSampleType.quantityType(forIdentifier: .height)
            case "weight":
                return HKSampleType.quantityType(forIdentifier: .bodyMass)
            case "distance_walking_running":
                return HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
            case "active_energy_burned":
                return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
            case "dietary_water":
                if #available(iOS 9, *) {
                    return HKSampleType.quantityType(forIdentifier: .dietaryWater)
                } else {
                    return nil
                }
            case "sleep_analysis":
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
            case "step_count":
                return HKUnit.count()
            case "height":
                return HKUnit.meter()
            case "weight":
                return HKUnit.gramUnit(with: .kilo)
            case "distance_walking_running":
                return HKUnit.meter()
            case "active_energy_burned":
                if #available(iOS 11, *) {
                    return HKUnit.largeCalorie()
                } else {
                    return HKUnit.calorie()
                }
            case "dietary_water":
                return HKUnit.liter()
            case "sleep_analysis":
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