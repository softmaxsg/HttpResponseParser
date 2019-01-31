//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

struct PayloadMock: Equatable, Codable {
    
    let value: String

}

extension PayloadMock {
    
    static func random() -> PayloadMock {
        return PayloadMock(value: .random())
    }
    
    var json: [String: Any] {
        return [
            "value": value
        ]
    }
    
}
