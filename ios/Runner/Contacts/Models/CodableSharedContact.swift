//
//  CodableSharedContact.swift
//  Runner
//
//  Created by Johannes Nevels on 29/01/2024.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

import Foundation

struct CodableSharedContact: Codable, Hashable {
    let phoneNumber: Int64
    let displayName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(phoneNumber)
    }

    static func == (lhs: CodableSharedContact, rhs: CodableSharedContact) -> Bool {
        return lhs.phoneNumber == rhs.phoneNumber
    }
}
