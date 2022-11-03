import Foundation

class Logger: NSObject, NativeLogging {

    private static let CONSOLE_LOG_KEY = "VIALER-PIL"
    private static let LOGGER_NAME = "IPL"
    
    private var anonymizationRules = [NSRegularExpression : String]()
    private var loggingDatabase: LoggingDatabase = LoggingDatabase()
    private var userIdentifier: String? = nil
    private var isConsoleLoggingEnabled = false

    private let flutterSharedPreferences = FlutterSharedPreferences()

    internal func writeLog(_ message: String) {
        if isConsoleLoggingEnabled {
            logToConsole(message: message)
        }

        logToDatabase(message: message)
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
    
    private func logToDatabase(message: String) {
        let message = anonymize(message: message)
        let userIdentifier = userIdentifier ?? ""
        
        loggingDatabase?.insertLog(message: "\(userIdentifier) \(message)", loggerName: Logger.LOGGER_NAME)
    }
    
    private func anonymize(message: String) -> String {
        return anonymizationRules.reduce(message, { partialResult, entry in
            entry.key.stringByReplacingMatches(in: partialResult, options: [], range: NSMakeRange(0, partialResult.count), withTemplate: entry.value)
        })
    }
    
    func startNativeConsoleLoggingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        isConsoleLoggingEnabled = true
    }
    
    func stopNativeConsoleLoggingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        isConsoleLoggingEnabled = false
    }
}
