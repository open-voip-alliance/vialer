import Foundation

struct AppConstants {
    static let appGroupIdentifier: String? = {
        return Bundle.main.object(forInfoDictionaryKey: "App Group identifier") as? String
    }()
    static let callDirectoryExtensionIdentifier: String? = {
        return Bundle.main.object(forInfoDictionaryKey: "Call Directory extension identifier") as? String
    }()
    
    static let contactsDataKey = "contactsData"
    static let contactsHashKey = "contactsHash"
}
