//
//  SharedContactApi.swift
//  Runner
//
//  Created by Johannes Nevels on 29/01/2024.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

import Foundation
import CallKit

class SharedContactsApi: NSObject, SharedContacts {
    func processSharedContactsContacts(_ contacts: [NativeSharedContact], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)

        var codableContacts = Set<CodableSharedContact>()

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

        let sortedContacts = codableContacts.sorted { $0.phoneNumber < $1.phoneNumber }
        let contactsData = try? JSONEncoder().encode(sortedContacts)

        let newHash = contactsData?.hashValue
        let oldHash = userDefaults?.integer(forKey: AppConstants.contactsHashKey)

        if newHash != oldHash {
            userDefaults?.set(contactsData, forKey: AppConstants.contactsDataKey)
            userDefaults?.set(newHash, forKey: AppConstants.contactsHashKey)

            CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: AppConstants.callDirectoryExtensionIdentifier) { error in
                if let error = error {
                    print("Error reloading extension: \(error)")
                } else {
                    print("Successfully reloaded extension.")
                }
            }
         }
    }
}
