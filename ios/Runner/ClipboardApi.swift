import UIKit

class NativeClipboardApi: NSObject, NativeClipboard {
    func hasPhoneNumber(completion: @escaping (Result<Bool, Error>) -> Void) {
        let pasteboard = UIPasteboard.general
        if #available(iOS 15, *), pasteboard.hasStrings {
            pasteboard.detectPatterns(for: [\.phoneNumbers]) { result in
                switch result {
                case .success(let patterns):
                    let hasPhoneNumber = patterns.contains(\.phoneNumbers)
                    completion(.success(hasPhoneNumber))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Handle the case where the clipboard is empty or the iOS version is earlier than 15
            completion(.success(false))
        }
    }
}
