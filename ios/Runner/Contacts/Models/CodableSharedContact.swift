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
