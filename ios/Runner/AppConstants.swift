//
//  AppConstants.swift
//  Runner
//
//  Created by Johannes Nevels on 30/01/2024.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

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
