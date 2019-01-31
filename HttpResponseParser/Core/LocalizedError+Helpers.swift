//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

extension LocalizedError {
    
    func errorDescription(key: String, underlying error: Error? = nil) -> String? {
        let message = NSLocalizedString(key, bundle: Bundle(for: BundleIdentifier.self), comment: "")
        let underlyingMessage = (error as? LocalizedError)?.failureReason ?? error?.localizedDescription
        return [message, underlyingMessage]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: " ")
    }
    
}

private class BundleIdentifier { }
