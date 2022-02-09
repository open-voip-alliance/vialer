import Foundation

class FlutterSharedPreferences {
    
    private let FLUTTER_SHARED_PREF_SYSTEM_USER = "flutter.system_user"
    private let FLUTTER_SHARED_PREF_VOIP_CONFIG = "flutter.voip_config"
    private let FLUTTER_SHARED_PREF_PUSH_TOKEN = "flutter.push_token"
    private let FLUTTER_SHARED_PREF_SETTINGS = "flutter.settings"

    let defaults = UserDefaults.standard
    
    var systemUser: [String: Any]? {
        get {
            convertToDictionary(text: defaults.string(forKey: FLUTTER_SHARED_PREF_SYSTEM_USER) ?? "")
        }
    }
    
    var voipConfig: [String: Any]? {
        get {
            convertToDictionary(text: defaults.string(forKey: FLUTTER_SHARED_PREF_VOIP_CONFIG) ?? "")
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
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func convertToArray(text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            } catch {
                print(error.localizedDescription)
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
}
