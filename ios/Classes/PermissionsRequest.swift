//
// Created by Martin Anderson on 2019-03-21.
//

import HealthKit

class PermissionsRequest {
    let types: Array<String>
    let quantityTypes: Array<HKQuantityType>

    private init(types: Array<String>, quantityTypes: Array<HKQuantityType>) {
        self.types = types;
        self.quantityTypes = quantityTypes
    }

    static func fromCall(call: FlutterMethodCall) throws -> PermissionsRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let types = arguments["types"] as? Array<String> else {
            throw "invalid call arguments \(call.arguments)";
        }

        let quantityTypes = try types.map { type -> HKQuantityType in
            try HKQuantityType.fromDartType(type: type)
        }

        return PermissionsRequest(types: types, quantityTypes: quantityTypes)
    }
}
