import Foundation
import CallKit

class SharedContactsApi: NSObject, SharedContacts {
    
    /**
     Processes the shared contacts and updates the call directory extension if necessary.
     
     - Parameters:
        - contacts: An array of NativeSharedContact objects representing the shared contacts.
        - error: A pointer to a FlutterError object that will be populated with an error if one occurs during the process.
     */
    func processSharedContacts(contacts: [NativeSharedContact]) throws {
        let userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)

        // Use a set to avoid duplicates
        var codableContacts = Set<CodableSharedContact>()
        
        // Save both phone numbers with and without calling code to have a better chance of matching incoming calls
        for contact in contacts {
            for phoneNumber in contact.phoneNumbers {
                codableContacts.add(phoneNumber: phoneNumber?.phoneNumberFlat, forContact: contact)
                codableContacts.add(phoneNumber: phoneNumber?.phoneNumberWithoutCallingCode, forContact: contact)
            }
        }
        
        // Required to sort the contacts ascending to store them correctly in the calls directory
        let sortedContacts = codableContacts.sorted { $0.phoneNumber < $1.phoneNumber }
        
        let contactsData = try? JSONEncoder().encode(sortedContacts)

        let newHash = createHash(sortedContacts)
        let oldHash = userDefaults?.integer(forKey: AppConstants.contactsHashKey)

        // Compare hashes to avoid unnecessary updates
        if newHash != oldHash, let callDirectoryExtensionIdentifier = AppConstants.callDirectoryExtensionIdentifier {
            userDefaults?.set(contactsData, forKey: AppConstants.contactsDataKey)
            userDefaults?.set(newHash, forKey: AppConstants.contactsHashKey)
            
            CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: callDirectoryExtensionIdentifier) { error in
                if let error = error {
                    Logger().writeLog("Error reloading CallDirectory extension: \(error)")
                }
            }
         }
    }
}

/// Calculates the hash value for an array of CodableSharedContact objects.
/// - Parameter contacts: An array of CodableSharedContact objects.
/// - Returns: The hash value calculated for the array of contacts.
private func createHash(_ contacts: [CodableSharedContact]) -> Int {
    var hasher = Hasher()
    for contact in contacts {
        hasher.combine(contact.phoneNumber)
        hasher.combine(contact.displayName)
    }
    return hasher.finalize()
}

extension Set<CodableSharedContact> {
    mutating func add(phoneNumber: String?, forContact contact: NativeSharedContact) {
        guard let phoneNumber = phoneNumber,
              let cxCallDirectoryPhoneNumber = CXCallDirectoryPhoneNumber(phoneNumber) else {
            return
        }
    
        let codableContact = CodableSharedContact(phoneNumber: cxCallDirectoryPhoneNumber, displayName: contact.displayName)
        insert(codableContact)
    }
}
