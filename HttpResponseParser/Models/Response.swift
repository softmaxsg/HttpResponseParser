//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

enum Response<T> where T: Decodable {
    
    case payload(T)
    case error(ResponseError)
    
}

extension Response: Decodable {

    enum CodingKeys: String, CodingKey  {
        case result
        case error = "message"
        case payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let result = try container.decodeBool(forKey: .result)
        if result {
            self = .payload(try container.decode(T.self, forKey: .payload))
        } else {
            self = .error(try container.decodeIfPresent(ResponseError.self, forKey: .error) ?? .unknown)
        }
    }
    
}
