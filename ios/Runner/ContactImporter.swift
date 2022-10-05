import Foundation
import Contacts

class ContactImporter: NSObject, Contacts {
    
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func fetch(completion: @escaping ([PigeonContact]?, FlutterError?) -> Void) {
         DispatchQueue.main.async {
            let results = self.findAllContacts().map { contact in
                PigeonContact.makeWith(
                    givenName: contact.givenName,
                    middleName: contact.middleName,
                    familyName: contact.familyName,
                    chosenName: nil,
                    phoneNumbers: contact.phoneNumbers.toPhoneItems(),
                    emails: contact.emailAddresses.toEmailItems(),
                    identifier:  contact.identifier,
                    company: contact.organizationName
                )
            }
             
             completion(results, nil)
        }
    }
    
    private func findAllContacts(withImages: Bool = false) -> [CNContact] {
        let store = CNContactStore()
        
        let keysToFetch = withImages
        ? [CNContactIdentifierKey, CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
        : [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactIdentifierKey, CNContactOrganizationNameKey] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            var results = [CNContact]()
            
            try store.enumerateContacts(with: fetchRequest, usingBlock: { contact, _ in
                results.append(contact)
            })
            
            return results
        } catch {
            logger.writeLog("Contact look-up failed: \(error)")
            return []
        }
    }
    
    func importContactAvatarsAvatarDirectoryPath(_ avatarDirectoryPath: String, completion: @escaping (FlutterError?) -> Void) {
        DispatchQueue.main.async {
            let contacts = self.findAllContacts(withImages: true)
                .filter { contact in contact.imageDataAvailable}
                
            contacts.forEach { contact in
                if let imageData = contact.thumbnailImageData {
                    (imageData as NSData).write(
                        toFile: "\(avatarDirectoryPath)/\(contact.identifier).jpg",
                        atomically: true
                    )
                }
            }
            
            DispatchQueue.main.async {
                self.removeOrphanedAvatars(
                    directory: avatarDirectoryPath,
                    validIds: contacts.map { contact in
                        contact.identifier
                    })
            }
            
            completion(nil)
        }
    }
    
    private func removeOrphanedAvatars(directory: String, validIds: [String]) {
        let files = FileManager.default
        
        do {
            try files.contentsOfDirectory(atPath: directory).forEach { filePath in
                if !validIds.contains(NSString(string: filePath).deletingPathExtension) {
                    try files.removeItem(atPath: "\(directory)/\(filePath)")
                }
            }
        } catch {
            logger.writeLog("Unable to remove orphaned avatars: \(error)")
        }
    }
}

extension [CNLabeledValue<CNPhoneNumber>]  {
    func toPhoneItems() -> [PigeonContactItem] {
        return map({ phoneNumber in
            PigeonContactItem.make(
                withLabel: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: phoneNumber.label ?? ""),
                value: phoneNumber.value.stringValue
            )
        })
    }
}

extension [CNLabeledValue<NSString>]  {
    func toEmailItems() -> [PigeonContactItem] {
        return map({ emailAddress in
            PigeonContactItem.make(
                withLabel: CNLabeledValue<NSString>.localizedString(forLabel: emailAddress.label ?? ""),
                value: emailAddress.value as String
            )
        })
    }
}
