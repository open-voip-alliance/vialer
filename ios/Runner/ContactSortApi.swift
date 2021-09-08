import Contacts

class ContactSortApi: NSObject, ContactSortHostApi {
    func getSortingWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> ContactSort? {
        let contactSort = ContactSort()
        switch CNContactsUserDefaults.shared().sortOrder {
        case .givenName:
            contactSort.orderBy = OrderBy.givenName
        case .familyName:
            contactSort.orderBy = OrderBy.familyName
        default:
            contactSort.orderBy = OrderBy.givenName
        }
        return contactSort
    }
}
