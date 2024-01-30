//
//  AppConstants.swift
//  Runner
//
//  Created by Johannes Nevels on 30/01/2024.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

import Foundation

struct AppConstants {
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "default"
    static let appGroupIdentifier = "group." + bundleIdentifier
    static let callDirectoryExtensionIdentifier = bundleIdentifier + ".CallDirectoryExtension"
    static let contactsDataKey = "contactsData"
    static let contactsHashKey = "contactsHash"
}
