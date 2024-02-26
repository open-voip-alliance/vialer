import UIKit

class NativeClipboardApi: NSObject, NativeClipboard {
    func hasPhoneNumber(completion: @escaping (Result<Bool, Error>) -> Void) {
        if #available(iOS 15, *) {
            UIPasteboard.general.detectPatterns(for: [\.phoneNumbers]) { result in
                switch result {
                case .success(let patterns):
                    let hasPhoneNumber = patterns.contains(\.phoneNumbers)
                    completion(.success(hasPhoneNumber))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Fallback on earlier versions
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "iOS 15 is required"])))
        }
    }
}
