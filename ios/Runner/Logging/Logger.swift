import Foundation
import Alamofire

class Logger: NSObject, NativeLogging {
    private static let CONSOLE_LOG_KEY = "VIALER-IPL"
    private static let LOGGER_NAME = "IPL"
    
    private var anonymizationRules = [NSRegularExpression : String]()
    private lazy var loggingDatabase: LoggingDatabase = {
        LoggingDatabase()
    }()
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
        
        loggingDatabase.insertLog(message: "\(userIdentifier) \(message)", loggerName: Logger.LOGGER_NAME)
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
    
    func uploadPendingLogsBatchSize(_ batchSize: NSNumber, packageName: String, appVersion: String, remoteLoggingId: String, url: String, logToken: String, completion: @escaping (FlutterError?) -> Void) {
        let dbLogs = loggingDatabase.getLogs(batchSize: batchSize)

        let logs = dbLogs.map { dbLog in
            let message = [
                "user": remoteLoggingId,
                "logged_from": dbLog.name,
                "message": dbLog.message,
                "level": String(dbLog.level.rawValue),
                "app_version": appVersion,
            ]
            
            let json = try! JSONEncoder().encode(message)
            
            return RemoteLoggingMessage(
                time: String(dbLog.log_time*1000*1000),
                message: String(decoding: json, as: UTF8.self)
            )
        }

        if (logs.isEmpty) {
            debugPrint("No logs to upload to Loki.")
            completion(nil)
            return
        }
        
        let lokiBatch = [
            "token": logToken,
            "app_id": packageName,
            "logs": logs.map({ remoteLoggingMessage in
                return [remoteLoggingMessage.time, remoteLoggingMessage.message]
            }),
        ] as [String : Any]
                
        let request = createLokiRequest(
            url: url,
            data: try! JSONSerialization.data(withJSONObject: lokiBatch)
        )
        
        AF.request(request).validate().responseString { response in
            switch response.result {
            case .success(_):
                debugPrint("Loki responded with success. Deleting sent logs from db")
                for dbLog in dbLogs {
                    self.loggingDatabase.deleteLog(id: dbLog.id)
                }
            case .failure(_):
                let statusCode = response.response?.statusCode
                let errorMessage = "Loki respond failed: response code was \(String(describing: statusCode))"
                debugPrint(errorMessage)
                completion(FlutterError(
                    code: String(describing: type(of: response.error)),
                    message: errorMessage,
                    details: Thread.callStackSymbols.joined(separator: "\n")
                ))
            }
        }
                                           
        completion(nil)
    }
    
    func removeStoredLogsKeepPastDay(_ keepPastDay: NSNumber, completion: @escaping (FlutterError?) -> Void) {
        loggingDatabase.deleteLogs(keepPastDay: keepPastDay.boolValue)
        completion(nil)
    }
    
    private func createLokiRequest(url: String, data: Data) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        return request
    }
}

struct RemoteLoggingMessage: Encodable {
    let time: String
    let message: String
}
