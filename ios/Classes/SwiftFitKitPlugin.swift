import Flutter
import UIKit
import HealthKit

public class SwiftFitKitPlugin: NSObject, FlutterPlugin {

    private let TAG = "FitKit";

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fit_kit", binaryMessenger: registrar.messenger())
        let instance = SwiftFitKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private var healthStore: HKHealthStore? = nil;

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: TAG, message: "Not supported", details: nil))
            return
        }

        if (healthStore == nil) {
            healthStore = HKHealthStore();
        }

        do {
            if (call.method == "hasPermissions") {
                let request = try PermissionsRequest.fromCall(call: call)
                hasPermissions(request: request, result: result)
            } else if (call.method == "requestPermissions") {
                let request = try PermissionsRequest.fromCall(call: call)
                requestPermissions(request: request, result: result)
            } else if (call.method == "revokePermissions") {
                revokePermissions(result: result)
            } else if (call.method == "read") {
                let request = try ReadRequest.fromCall(call: call)
                read(request: request, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: TAG, message: "Error \(error)", details: nil))
        }
    }


    /**
    * On iOS you can only know if user has responded to request access screen.
    * Not possible to tell if he has allowed access to read.
    *
    *   # getRequestStatusForAuthorization #
    *   If "status == unnecessary" means if requestAuthorization will be called request access screen will not be shown.
    *   So user has already responded to request access screen and kinda has permissions.
    *
    *   # authorizationStatus #
    *   If "status == notDetermined" user has not responded to request access screen.
    *   Once he responds no matter of the result status will be sharingDenied.
    */
    private func hasPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            healthStore!.getRequestStatusForAuthorization(toShare: [], read: Set(request.quantityTypes)) { (status, error) in
                guard error == nil else {
                    result(FlutterError(code: self.TAG, message: "hasPermissions", details: error))
                    return
                }

                guard status == HKAuthorizationRequestStatus.unnecessary else {
                    result(false)
                    return
                }

                result(true)
            }
        } else {
            let authorized = request.quantityTypes.map {
                        healthStore!.authorizationStatus(for: $0)
                    }
                    .allSatisfy {
                        $0 != HKAuthorizationStatus.notDetermined
                    }
            result(authorized)
        }
    }

    private func requestPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        requestAuthorization(quantityTypes: request.quantityTypes) { success, error in
            guard success else {
                result(false)
                return
            }

            result(true)
        }
    }

    /**
    * Not supported by HealthKit.
    */
    private func revokePermissions(result: @escaping FlutterResult) {
        result(nil)
    }

    private func read(request: ReadRequest, result: @escaping FlutterResult) {
        requestAuthorization(quantityTypes: [request.quantityType]) { success, error in
            guard success else {
                result(error)
                return
            }

            self.readSample(request: request, result: result)
        }
    }

    private func requestAuthorization(quantityTypes: Array<HKQuantityType>, completion: @escaping (Bool, FlutterError?) -> Void) {
        healthStore!.requestAuthorization(toShare: nil, read: Set(quantityTypes)) { (success, error) in
            guard success else {
                completion(false, FlutterError(code: self.TAG, message: "Error \(error?.localizedDescription ?? "empty")", details: nil))
                return
            }

            completion(true, nil)
        }
    }

    private func readSample(request: ReadRequest, result: @escaping FlutterResult) {
        print("readSample: \(request.type)")

        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom,
                                                    end: request.dateTo,
                                                    options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                              ascending: request.limit == nil)

        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday],
                                                       from: request.dateFrom)

        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }

        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: request.quantityType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler =  { (query, statisticsCollection, error) in
            guard var statisticsCollection = statisticsCollection?.statistics() else {
               result(FlutterError(code: self.TAG, message: "Results are null", details: error))
               return
            }
            if (request.limit != nil) {
               // if limit is used sort back to ascending
                statisticsCollection = statisticsCollection
                .sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
            }

            print(statisticsCollection)
            result(statisticsCollection.map { statistics -> NSDictionary in
               [
                   "value": self.readValue(statistics: statistics, unit: request.unit),
                   "date_from": Int(statistics.startDate.timeIntervalSince1970 * 1000),
                   "date_to": Int(statistics.endDate.timeIntervalSince1970 * 1000),
                   "source": "HKQuantityType",
               ]
            } ?? [])
        }
        healthStore!.execute(query)
    }

    private func readValue(statistics: HKStatistics, unit: HKUnit) -> Any {
        if let quatity = statistics.sumQuantity() {
            return quatity.doubleValue(for: unit)
        } else {
            return -1
        }
    }
}
