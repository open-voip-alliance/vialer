import Contacts

class ContactSortApi: NSObject, ContactSortHostApi {
    func getSortingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> ContactSort? {
        let contactSort = switch CNContactsUserDefaults.shared().sortOrder {
            case .givenName: OrderBy.givenName
            case .familyName: OrderBy.familyName
            default: OrderBy.givenName
        }
        
        return ContactSort.makeWithOrder(by: OrderByBox(value: contactSort))
    }
}
