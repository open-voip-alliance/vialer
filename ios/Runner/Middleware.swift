import flutter_phone_lib
import PushKit
import Alamofire

public class Middleware: NativeMiddleware {
    
    private let logger: Logger
    private let segment: Segment
    
    private let BASE_URL = "https://vialerpush.voipgrid.nl/api/"
    private let RESPONSE_URL = "call-response/"
    private let REGISTER_URL = "apns-device/"
    
    private let flutterSharedPreferences = FlutterSharedPreferences()
    
    private var lastRegisteredToken: String?
    public var currentCallInfo: CurrentCallInfo?
    
    private static let secondsBeforeRejected = 8
    
    private var middlewareCredentials: MiddlewareCredentials {
        get {
            MiddlewareCredentials(
                email: flutterSharedPreferences.systemUser?["email"] as? String ?? "",
                loginToken: flutterSharedPreferences.systemUser?["token"] as? String ?? "",
                sipUserId: flutterSharedPreferences.voipConfig?["appaccount_account_id"] as? String ?? ""
            )
        }
    }

    init(logger: Logger, segment: Segment) {
        self.logger = logger
        self.segment = segment
    }
        
    public func tokenReceived(token: String) {
        if (lastRegisteredToken == token) {
            return
        }
        
        lastRegisteredToken = token
        
        if (flutterSharedPreferences.getBoolSetting(name: "DndSetting")) {
            logger.writeLog("Registration cancelled: do not disturb is enabled")
            return
        }
        
        let data = [
            "name": middlewareCredentials.email,
            "token": token,
            "sip_user_id": middlewareCredentials.sipUserId,
            "os_version": UIDevice.current.systemVersion,
            "client_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            "app": Bundle.main.bundleIdentifier,
            "push_profile": "once",
            "sandbox": Bundle.main.infoDictionary?["Sandbox"] as? String
        ]
                
        var request = createMiddlewareRequest(email: middlewareCredentials.email, token: middlewareCredentials.loginToken, url: REGISTER_URL)

        request.httpBody = try! JSONSerialization.data(withJSONObject: data)

        AF.request(request).responseData { (response) -> Void in
            if response.error != nil {
                self.logger.writeLog("Registration failed: \(response.error!)")
                self.lastRegisteredToken = nil
            }
            
            switch response.result {
            case .success(_):
                self.logger.writeLog("Registration successful")
            case .failure(_):
                let statusCode = response.response?.statusCode
                self.logger.writeLog("Registration failed: response code was \(String(describing: statusCode))")
                self.lastRegisteredToken = nil
           }
        }
        
        flutterSharedPreferences.pushToken = token
    }
    
    public func respond(payload: PKPushPayload, available: Bool) {
        payload.dictionaryPayload.forEach { (key, value) in
            print("TEST123 - \(key) - \(value)")
        }
        let payloadDictionary = payload.dictionaryPayload as NSDictionary
        let callId = payloadDictionary.value(forKey: "unique_key")
        let callStartTime = payloadDictionary.value(forKey: "message_start_time")
        let pushResponseTime = payload.secondsSincePushWasSent
        
        logger.writeLog("Middleware Respond: Attempting for call=\(String(describing: callId)), available=\(available)")
        
        if pushResponseTime > Middleware.secondsBeforeRejected {
            logger.writeLog("The response time is $pushResponseTime, it is likely we are too late for this call.")
        }
        
        let data = [
            "unique_key": callId,
            "available": String(available),
            "message_start_time": callStartTime,
            "sip_user_id": middlewareCredentials.sipUserId,
        ]
        
        var request = createMiddlewareRequest(email: middlewareCredentials.email, token: middlewareCredentials.loginToken, url: RESPONSE_URL)

        request.httpBody = try! JSONSerialization.data(withJSONObject: data)
        
        let track: (_ middlewareResponse: String) -> Void = { (response) in
            self.trackNotificationResult(
                payload: payload,
                middlewareResponse: response,
                available: available,
                reason: "tbd",
                responseTime: pushResponseTime
            )
        }
        
        AF.request(request).response { (response) -> Void in
            if response.error != nil {
                self.logger.writeLog("Middleware respond failed: \(response.error!)")
                self.lastRegisteredToken = nil
                track(response.error?.errorDescription ?? "error")
                return
            }
            
            track(String(response.response?.statusCode ?? 0))
            
            switch response.result {
                case .success(_):
                    self.logger.writeLog("Middleware respond success: \(String(describing: callId))")
                case .failure(_):
                    let statusCode = response.response?.statusCode
                    self.logger.writeLog("Middleware respond failed: response code was \(String(describing: statusCode))")
                    self.lastRegisteredToken = nil
           }
        }
        
        if available {
            currentCallInfo = payload.toCurrentCallInfo()
        }
    }
    
    public func inspect(payload: PKPushPayload, type: PKPushType) {
        segment.track(event: "notification-received", properties: [
            "seconds_from_call_to_received" : payload.secondsSincePushWasSent,
        ])
    }
    
    public func extractCallDetail(from payload: PKPushPayload) -> CallDetail {
        let phoneNumber = payload.dictionaryPayload["phonenumber"] as? String ?? ""
        let callerId = payload.dictionaryPayload["caller_id"] as? String ?? ""
        
        return CallDetail(phoneNumber: phoneNumber, callId: callerId)
    }
    
    private func trackNotificationResult(payload: PKPushPayload, middlewareResponse: String, available: Bool, reason: String, responseTime: Int) {
        segment.track(event: "notification-result", properties: payload.withTrackingProperties(properties: [
            "middleware_response" : middlewareResponse,
            "available" : String(available),
            "unavailable_reason" : "reason",
            "seconds_from_call_to_responded" : String(responseTime),
        ]))
    }

    private func createMiddlewareRequest(email: String, token: String, url: String) -> URLRequest {
        var request = URLRequest(url:  NSURL(string: BASE_URL+url)! as URL)

        request.httpMethod = "POST"
        request.setValue("Token \(email):\(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

private struct MiddlewareCredentials {
    let email: String
    let loginToken: String
    let sipUserId: String
}

extension PKPushPayload {
    
    var callId: String {
        return dictionaryPayload["unique_key"] as? String ?? "abc"
    }
    
    var correlationId: String {
        return dictionaryPayload["correlation_id"] as? String ?? ""
    }
    
    var messageStartTime: Int {
        return Int(dictionaryPayload["message_start_time"] as? Double ?? 0.0)
    }
    
    var isCall: Bool {
        return (dictionaryPayload["type"] as? String ?? "") == "call"
    }
    
    var trackingProperties: [String : String] {
        return [
            "call_id" : callId,
            "correlation_id" : correlationId,
            "message_start_time" : String(messageStartTime),
            "push_sent_time" : String(messageStartTime),
        ]
    }
    
    func withTrackingProperties(properties: [String : String]) -> [String : String] {
        return trackingProperties.merging(properties) { (current,_) in current }
    }
    
    var secondsSincePushWasSent: Int {
        return Int((Date().timeIntervalSince1970)) - messageStartTime
    }
    
    func toCurrentCallInfo() -> CurrentCallInfo {
        return CurrentCallInfo(
            callId: callId,
            correlationId: correlationId,
            pushReceivedTime: String(Int(Date().timeIntervalSince1970) * 1000)
        )
    }
}

public struct CurrentCallInfo {
    public let callId: String
    public let correlationId: String
    public let pushReceivedTime: String
}
