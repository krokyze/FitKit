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
    public static func fromDartType(type: String) -> HKSampleType? {
        switch type {
        case "heart_rate":
            return HKSampleType.quantityType(forIdentifier: .heartRate)
        case "step_count":
            return HKSampleType.quantityType(forIdentifier: .stepCount)
        case "height":
            return HKSampleType.quantityType(forIdentifier: .height)
        case "weight":
            return HKSampleType.quantityType(forIdentifier: .bodyMass)
        default:
            return nil
        }
    }
}

extension HKUnit {
    public static func fromDartType(type: String) -> HKUnit? {
        switch (type) {
        case "heart_rate":
            return HKUnit.init(from: "count/min")
        case "step_count":
            return HKUnit.count()
        case "height":
            return HKUnit.meter()
        case "weight":
            return HKUnit.gramUnit(with: .kilo)
        default:
            return nil
        }
    }
}