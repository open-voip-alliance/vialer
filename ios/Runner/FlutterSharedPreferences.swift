import Foundation

class FlutterSharedPreferences {
    
    private let FLUTTER_SHARED_PREF_SYSTEM_USER = "flutter.system_user"
    private let FLUTTER_SHARED_PREF_PUSH_TOKEN = "flutter.push_token"
    private let FLUTTER_SHARED_PREF_SETTINGS = "flutter.settings"
    private let FLUTTER_SHARED_PREF_LOGS = "flutter.logs"
    private let FLUTTER_SHARED_PREF_IS_LOGGED_IN_SOMEWHERE_ELSE = "flutter.is_logged_in_somewhere_else"
    private let FLUTTER_SHARED_PREF_REMOTE_NOTIFICATION_TOKEN = "flutter.remote_notification_token"
    private let FLUTTER_SHARED_PREF_LOGIN_TIME = "flutter.login_time"
    
    private let appendLogsQueue = DispatchQueue(label: "appendLogsQueue")

    let defaults = UserDefaults.standard
    
    var systemUser: [String: Any]? {
        get {
            convertToDictionary(text: defaults.string(forKey: FLUTTER_SHARED_PREF_SYSTEM_USER) ?? "")
        }
    }
    
    var middlewareUrl: String {
        get {
            let client = (systemUser?["client"] as? [String : Any])
            let voip = (client?["voip"] as? [String : Any])
            let fallbackUrl = (Bundle.main.infoDictionary?["MiddlewareUrl"] as? String)!.removingPercentEncoding!
            
            return voip?["MIDDLEWARE"] as? String ?? fallbackUrl
        }
    }
    
    var pushToken: String {
        get {
           defaults.string(forKey: FLUTTER_SHARED_PREF_PUSH_TOKEN) ?? ""
        }
        set (value) {
            defaults.set(value, forKey: FLUTTER_SHARED_PREF_PUSH_TOKEN)
            defaults.synchronize()
        }
    }
    
    var remoteNotificationToken: String {
        get {
            defaults.string(forKey: FLUTTER_SHARED_PREF_REMOTE_NOTIFICATION_TOKEN) ?? ""
        }
        set (value) {
            defaults.set(value, forKey: FLUTTER_SHARED_PREF_REMOTE_NOTIFICATION_TOKEN)
            defaults.synchronize()
        }
    }
    
    var isLoggedInSomewhereElse: Bool {
        get {
            defaults.bool(forKey: FLUTTER_SHARED_PREF_IS_LOGGED_IN_SOMEWHERE_ELSE)
        }
        set (value) {
            defaults.set(value, forKey: FLUTTER_SHARED_PREF_IS_LOGGED_IN_SOMEWHERE_ELSE)
            defaults.synchronize()
        }
    }
    
    // Formatted as a iso8601 string.
    var loginTime: String {
        get {
            defaults.string(forKey: FLUTTER_SHARED_PREF_LOGIN_TIME) ?? ""
        }
    }

    private var settings: [Any]? {
        get {
            convertToArray(text: defaults.string(forKey: FLUTTER_SHARED_PREF_SETTINGS) ?? "")
        }
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    private func convertToArray(text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    func getSetting(name: String, defaultValue: String = "") -> String {
        guard let settings = settings else {return defaultValue}
        
        for item in settings {
            guard let setting = item as? [String:Any],
                  let settingName = setting["type"] as? String,
                  let settingBoolValue = setting["value"] as? Bool
            else {continue}

            if (settingName == name) {
                let settingValue = String(settingBoolValue)
                return settingValue
            }
        }

        return defaultValue
    }
    
    func getBoolSetting(name: String, defaultValue: Bool = false) -> Bool {
        Bool(getSetting(name: name, defaultValue: String(defaultValue))) ?? defaultValue
    }
    
    private var logs: String {
        get {
           defaults.string(forKey: FLUTTER_SHARED_PREF_LOGS) ?? ""
        }
        set (value) {
            defaults.set(value, forKey: FLUTTER_SHARED_PREF_LOGS)
            defaults.synchronize()
        }
    }
    
    func appendLogs(value: String) {
        appendLogsQueue.async {
            self.logs = "\(self.logs)\n\(value)"
        }
    }
}
