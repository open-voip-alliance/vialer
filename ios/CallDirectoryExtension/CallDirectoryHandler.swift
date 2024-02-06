//
//  CallDirectoryHandler.swift
//  CallDirectoryExtension
//
//  Created by Johannes Nevels on 29/01/2024.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        if context.isIncremental {
            context.removeAllIdentificationEntries()
        }
        
        addAllIdentificationPhoneNumbers(to: context)

        context.completeRequest()
    }

    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        // Numbers must be provided in numerically ascending order.
        
        let userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
        if let contactsData = userDefaults?.data(forKey: AppConstants.contactsDataKey) {
            guard let contacts = try? JSONDecoder().decode([CodableSharedContact].self, from: contactsData) else { return }
            for entry in contacts {
                context.addIdentificationEntry(withNextSequentialPhoneNumber: entry.phoneNumber,
                                                label: entry.displayName)
            }
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print(error.localizedDescription)
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
