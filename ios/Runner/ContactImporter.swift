import Foundation
import Contacts

class ContactImporter: NSObject, Contacts {
    
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func importContacts(cacheFilePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let results = self.findAllContacts().map { contact in
                Contact(
                    givenName: contact.givenName,
                    middleName: contact.middleName,
                    familyName: contact.familyName,
                    chosenName: nil,
                    phoneNumbers: contact.phoneNumbers.map({ phoneNumber in
                        Item(
                            label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: phoneNumber.label ?? ""),
                            value: phoneNumber.value.stringValue
                        )
                    }),
                    emails: contact.emailAddresses.map({ emailAddress in
                        Item(
                            label: CNLabeledValue<NSString>.localizedString(forLabel: emailAddress.label ?? ""),
                            value: emailAddress.value as String
                        )
                    }),
                    identifier: contact.identifier,
                    company: contact.organizationName
                )
            }
            
            do {
                if !results.isEmpty {
                    let json = self.convertToJson(contacts: results)
                    try json.write(toFile: cacheFilePath, atomically: true, encoding: .utf8)
                }
            } catch {
                self.logger.writeLog("Contact importing failed: \(error)")
            }
            
            completion(Result.success(Void()))
        }
    }
    
    private func convertToJson(contacts: [Contact]) -> String {
        do {
            let data = try JSONEncoder().encode(contacts)
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            logger.writeLog("Unable to convert to JSON: \(error)")
            return "[]"
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
    
    func importContactAvatars(avatarDirectoryPath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
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
            
            completion(Result.success(Void()))
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

struct Contact : Codable {
    internal init(givenName: String? = nil, middleName: String? = nil, familyName: String? = nil, chosenName: String? = nil, phoneNumbers: [Item], emails: [Item], identifier: String? = nil, company: String? = nil) {
        self.givenName = givenName
        self.middleName = middleName
        self.familyName = familyName
        self.chosenName = chosenName
        self.phoneNumbers = phoneNumbers
        self.emails = emails
        self.identifier = identifier
        self.company = company
    }
    
    let givenName: String?
    let middleName: String?
    let familyName: String?
    let chosenName: String?
    let phoneNumbers: [Item]
    let emails: [Item]
    let identifier: String?
    let company: String?
}
    
struct Item : Codable {
    internal init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    let label: String
    let value: String
}
