import flutter_phone_lib
import PushKit
import Alamofire

public class Middleware: NativeMiddleware {
    
    private let logger: Logger
    
    private let BASE_URL = "https://vialerpush.voipgrid.nl/api/"
    private let RESPONSE_URL = "call-response/"
    private let REGISTER_URL = "apns-device/"
    
    private let flutterSharedPreferences = FlutterSharedPreferences()
    
    private var lastRegisteredToken: String?
    
    private var middlewareCredentials: MiddlewareCredentials {
        get {
            MiddlewareCredentials(
                email: flutterSharedPreferences.systemUser?["email"] as? String ?? "",
                loginToken: flutterSharedPreferences.systemUser?["token"] as? String ?? "",
                sipUserId: flutterSharedPreferences.voipConfig?["appaccount_account_id"] as? String ?? ""
            )
        }
    }

    init(logger: Logger) {
        self.logger = logger
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

        AF.request(request).responseJSON { (response) -> Void in
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
        let payloadDictionary = payload.dictionaryPayload as NSDictionary
        let callId = payloadDictionary.value(forKey: "unique_key")
        let callStartTime = payloadDictionary.value(forKey: "message_start_time")
        
        logger.writeLog("Middleware Respond: Attempting for call=\(String(describing: callId)), available=\(available)")
        
        let data = [
            "unique_key": callId,
            "available": String(available),
            "message_start_time": callStartTime,
            "sip_user_id": middlewareCredentials.sipUserId,
        ]
        
        var request = createMiddlewareRequest(email: middlewareCredentials.email, token: middlewareCredentials.loginToken, url: RESPONSE_URL)

        request.httpBody = try! JSONSerialization.data(withJSONObject: data)
        
        AF.request(request).responseJSON { (response) -> Void in
            if response.error != nil {
                self.logger.writeLog("Middleware respond failed: \(response.error!)")
                self.lastRegisteredToken = nil
            }
            
            switch response.result {
            case .success(_):
                self.logger.writeLog("Middleware respond success: \(String(describing: callId))")
            case .failure(_):
                let statusCode = response.response?.statusCode
                self.logger.writeLog("Middleware respond failed: response code was \(String(describing: statusCode))")
                self.lastRegisteredToken = nil
           }
        }
    }
    
    public func inspect(payload: PKPushPayload, type: PKPushType) {
        //TODO: Empty for now until we update this for metrics
    }
    
    public func extractCallDetail(from payload: PKPushPayload) -> CallDetail {
        let phoneNumber = payload.dictionaryPayload["phonenumber"] as? String ?? ""
        let callerId = payload.dictionaryPayload["caller_id"] as? String ?? ""
        
        return CallDetail(phoneNumber: phoneNumber, callId: callerId)
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
