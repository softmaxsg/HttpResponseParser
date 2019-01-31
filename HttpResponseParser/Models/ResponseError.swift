//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

public enum ResponseError: Error, Equatable {

    case unknown
    case failure(message: String)

}

extension ResponseError: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = .failure(message: try container.decode(String.self))
    }
    
}

extension ResponseError: LocalizedError {

    public var failureReason: String? {
        switch self {
        case .unknown:
            return errorDescription(key: "error.response.error.unknown")
        case .failure(let message):
            return message
        }
    }
    
}
