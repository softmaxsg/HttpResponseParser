//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import HttpResponseParser

extension ResponseError {
    
    var message: String? {
        switch self {
        case .failure(let message): return message
        case .unknown: return nil
        }
    }
    
}
