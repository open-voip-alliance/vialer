import Foundation

class Logger: NSObject, NativeLogging {

    private static let CONSOLE_LOG_KEY = "VIALER-PIL"
    private static let LOGGER_NAME = "IPL"
    
    private var anonymizationRules = [NSRegularExpression : String]()
    private var loggingDatabase: LoggingDatabase? = nil
    private var userIdentifier: String? = nil
    private var isConsoleLoggingEnabled = false
    private var isRemoteLoggingEnabled: Bool {
        loggingDatabase != nil
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
        dateFormatter.dateFormat = "uuuu-MM-dd HH:mm:ss.SSSSSS"
        let time = dateFormatter.string(from: Date())

        let formattedMessage = "[\(time)] \(Logger.LOGGER_NAME): \(message)"

        print("\(Logger.CONSOLE_LOG_KEY) \(formattedMessage)")

        if (flutterSharedPreferences.systemUser != nil) {
            flutterSharedPreferences.appendLogs(value: anonymize(message: formattedMessage))
        }
    }
    
    private func logToRemote(message: String) {
        let message = anonymize(message: message) //wip do we still need to anonymize and add the userIdentifier to the log message?
        let userIdentifier = userIdentifier ?? ""
        
        loggingDatabase?.insertLog(message: "\(userIdentifier) \(message)", loggerName: Logger.LOGGER_NAME)
    }
    
    private func anonymize(message: String) -> String {
        return anonymizationRules.reduce(message, { partialResult, entry in
            entry.key.stringByReplacingMatches(in: partialResult, options: [], range: NSMakeRange(0, partialResult.count), withTemplate: entry.value)
        })
    }
    
    //wip used by pigeon - do we need to apply any changes now that we don't use log entries? is token going to be used anywhere with Loki? Do we need this whole function? Do we need to change/remove the GetLoggingTokenUseCase? I guess in a another ticket for Loki epic.
    func startNativeRemoteLoggingToken(_ token: String?, userIdentifier: String?, anonymizationRules: [String : String]?, completion: @escaping (FlutterError?) -> Void) {
        loggingDatabase = LoggingDatabase()
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
        loggingDatabase = nil
        userIdentifier = nil
    }
    
    func stopNativeConsoleLoggingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        isConsoleLoggingEnabled = false
    }
}
