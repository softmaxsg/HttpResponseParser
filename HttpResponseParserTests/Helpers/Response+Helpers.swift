//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import HttpResponseParser

extension Response {
    
    var payload: T? {
        switch self {
        case .payload(let payload): return payload
        case .error: return nil
        }
    }
        
    var error: ResponseError? {
        switch self {
        case .payload: return nil
        case .error(let error): return error
        }
    }

}
