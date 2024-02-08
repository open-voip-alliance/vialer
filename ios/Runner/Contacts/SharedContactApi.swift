import Foundation
import CallKit

class SharedContactsApi: NSObject, SharedContacts {
    /**
     Processes the shared contacts and updates the call directory extension if necessary.
     
     - Parameters:
        - contacts: An array of NativeSharedContact objects representing the shared contacts.
        - error: A pointer to a FlutterError object that will be populated with an error if one occurs during the process.
     */
    func processSharedContactsContacts(_ contacts: [NativeSharedContact], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)

        // Use a set to avoid duplicates
        var codableContacts = Set<CodableSharedContact>()
        
        // Save both phone numbers with and without calling code to have a better chance of matching incoming calls
        for contact in contacts {
            for phoneNumber in contact.phoneNumbers {
                if let phoneNumberFlat = CXCallDirectoryPhoneNumber(phoneNumber.phoneNumberFlat) {
                    let codableContact = CodableSharedContact(phoneNumber: phoneNumberFlat, displayName: contact.displayName)
                    codableContacts.insert(codableContact)
                }
                
                if let phoneNumberWithoutCallingCode = CXCallDirectoryPhoneNumber(phoneNumber.phoneNumberWithoutCallingCode) {
                    let codableContact = CodableSharedContact(phoneNumber: phoneNumberWithoutCallingCode, displayName: contact.displayName)
                    codableContacts.insert(codableContact)
                }
            }
        }
        
        // Required to sort the contacts ascending to store them correctly in the calls directory
        let sortedContacts = codableContacts.sorted { $0.phoneNumber < $1.phoneNumber }
        
        let contactsData = try? JSONEncoder().encode(sortedContacts)

        let newHash = contactsData?.hashValue
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
 
