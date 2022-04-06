import Foundation
import le

class Logger: NSObject, NativeLogging {

    private static let CONSOLE_LOG_KEY = "VIALER-PIL"
    private var anonymizationRules = [NSRegularExpression : String]()
    private var logEntries: LELog? = nil
    private var userIdentifier: String? = nil
    private var isConsoleLoggingEnabled = false
    private var isRemoteLoggingEnabled: Bool {
        logEntries != nil
    }

    private let flutterSharedPreferences = FlutterSharedPreferences()

    internal func writeLog(_ message: String) {
        if isConsoleLoggingEnabled {
            logToConsole(message: message)
        }

        if isRemoteLoggingEnabled {
            logToRemote(message: message)
        }
    }

    private func logToConsole(message: String) {
        // Format message to be consistent with Dart logs.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "uuuu-MM-dd HH-mm-ss.SSSSSS"
        let time = dateFormatter.string(from: Date())

        let formattedMessage = "[\(time)] IPL: \(message)"

        print("\(Logger.CONSOLE_LOG_KEY) \(formattedMessage)")

        if (flutterSharedPreferences.systemUser != nil) {
            flutterSharedPreferences.appendLogs(value: anonymize(message: formattedMessage))
        }
    }
    
    private func logToRemote(message: String) {
        let message = anonymize(message: message)
        let userIdentifier = userIdentifier ?? ""
        
        logEntries?.log("\(userIdentifier) \(message)" as NSString)
    }
    
    private func anonymize(message: String) -> String {
        return anonymizationRules.reduce(message, { partialResult, entry in
            entry.key.stringByReplacingMatches(in: partialResult, options: [], range: NSMakeRange(0, partialResult.count), withTemplate: entry.value)
        })
    }
    
    func startNativeRemoteLoggingToken(_ token: String?, userIdentifier: String?, anonymizationRules: [String : String]?, completion: @escaping (FlutterError?) -> Void) {
        logEntries = LELog.session(withToken: token)
        logEntries?.debugLogs = false
        self.userIdentifier = userIdentifier
        
        do {
            self.anonymizationRules = try anonymizationRules?.reduce(into: [NSRegularExpression:String]()) { dict, entry in
                return dict[try NSRegularExpression(pattern: entry.key)] = entry.value
            } ?? [NSRegularExpression:String]()
        } catch {}
        
        completion(nil)
    }
    
    func startNativeConsoleLoggingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        isConsoleLoggingEnabled = true
    }
    
    func stopNativeRemoteLoggingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        logEntries = nil
        userIdentifier = nil
    }
    
    func stopNativeConsoleLoggingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        isConsoleLoggingEnabled = false
    }
}
