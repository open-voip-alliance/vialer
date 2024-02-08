import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
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
