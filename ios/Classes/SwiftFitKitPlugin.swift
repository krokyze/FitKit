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

        if (call.method == "requestPermissions") {
            do {
                let request = try PermissionsRequest.fromCall(call: call)
                requestPermissions(request: request, result: result)
            } catch {
                result(FlutterError(code: TAG, message: "Error \(error)", details: nil))
            }
        } else if (call.method == "read") {
            do {
                let request = try ReadRequest.fromCall(call: call)
                read(request: request, result: result)
            } catch {
                result(FlutterError(code: TAG, message: "Error \(error)", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func requestPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: request.sampleTypes) { success, error in
            guard success else {
                result(false)
                return
            }

            result(true)
        }
    }

    private func read(request: ReadRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: [request.sampleType]) { success, error in
            guard success else {
                result(error)
                return
            }

            self.readSample(request: request, result: result)
        }
    }

    private func requestAuthorization(sampleTypes: Array<HKSampleType>, completion: @escaping (Bool, FlutterError?) -> Void) {
        if (healthStore == nil) {
            healthStore = HKHealthStore();
        }

        healthStore!.requestAuthorization(toShare: nil, read: Set(sampleTypes)) { (success, error) in
            guard success else {
                completion(false, FlutterError(code: self.TAG, message: "Error \(error?.localizedDescription ?? "empty")", details: nil))
                return
            }

            completion(true, nil)
        }
    }

    private func readSample(request: ReadRequest, result: @escaping FlutterResult) {
        print("readSample: \(request.type)")

        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom, end: request.dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)

        let query = HKSampleQuery(sampleType: request.sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            _, samplesOrNil, error in

            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                result(FlutterError(code: self.TAG, message: "Results are null", details: error))
                return
            }

            print(samples)
            result(samples.map { sample -> NSDictionary in
                [
                    "value": sample.quantity.doubleValue(for: request.unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source": self.readSource(sample: sample),
                ]
            })
        }
        healthStore!.execute(query)
    }

    private func readSource(sample: HKQuantitySample) -> String {
        if #available(iOS 9, *) {
            return sample.sourceRevision.source.name;
        }

        return sample.source.name;
    }
}
