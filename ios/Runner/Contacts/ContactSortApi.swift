import Contacts

class ContactSortApi: NSObject, ContactSortHostApi {
    func getSortingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> ContactSort? {
        let contactSort: OrderBy

        switch CNContactsUserDefaults.shared().sortOrder {
            case .givenName: contactSort = OrderBy.givenName
            case .familyName: contactSort = OrderBy.familyName
            default: contactSort = OrderBy.givenName
        }
        
        return ContactSort.makeWithOrder(by: OrderByBox(value: contactSort))
    }
}
