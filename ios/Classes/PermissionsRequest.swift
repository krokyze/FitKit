//
// Created by Martin Anderson on 2019-03-21.
//

import HealthKit

class PermissionsRequest {
    let types: Array<String>
    let sampleTypes: Array<HKSampleType>

    private init(types: Array<String>, sampleTypes: Array<HKSampleType>) {
        self.types = types;
        self.sampleTypes = sampleTypes
    }

    static func fromCall(call: FlutterMethodCall) throws -> PermissionsRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let types = arguments["types"] as? Array<String> else {
            throw "invalid call arguments \(call.arguments)";
        }

        let sampleTypes = try types.map { type -> HKSampleType in
            try HKSampleType.fromDartType(type: type)
        }

        return PermissionsRequest(types: types, sampleTypes: sampleTypes)
    }
}
