//
// Created by Martin Anderson on 2019-03-10.
//

import HealthKit

class ReadRequest {
    let type: String
    let quantityType: HKQuantityType
    let unit: HKUnit

    let dateFrom: Date
    let dateTo: Date
    let limit: Int?

    private init(type: String, quantityType: HKQuantityType, unit: HKUnit, dateFrom: Date, dateTo: Date, limit: Int?) {
        self.type = type;
        self.quantityType = quantityType
        self.unit = unit
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.limit = limit
    }

    static func fromCall(call: FlutterMethodCall) throws -> ReadRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let type = arguments["type"] as? String,
              let dateFromEpoch = arguments["date_from"] as? NSNumber,
              let dateToEpoch = arguments["date_to"] as? NSNumber else {
            throw "invalid call arguments \(call.arguments)";
        }

        let quantityType = try HKQuantityType.fromDartType(type: type)
        let unit = try HKUnit.fromDartType(type: type)
        let dateFrom = Date(timeIntervalSince1970: dateFromEpoch.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: dateToEpoch.doubleValue / 1000)
        let limit = arguments["limit"] as? Int

        return ReadRequest(type: type, quantityType: quantityType, unit: unit, dateFrom: dateFrom, dateTo: dateTo, limit: limit)
    }
}
