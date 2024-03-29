//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

extension DecodingError {
    
    var isTypeMismatch: Bool {
        switch self {
        case .typeMismatch: return true
        default: return false
        }
    }
    
    var isValueNotFound: Bool {
        switch self {
        case .valueNotFound: return true
        default: return false
        }
    }
    
    var isKeyNotFound: Bool {
        switch self {
        case .keyNotFound: return true
        default: return false
        }
    }
    
    var isDataCorrupted: Bool {
        switch self {
        case .dataCorrupted: return true
        default: return false
        }
    }
    
    var context: DecodingError.Context {
        switch self {
        case .typeMismatch(_, let context): return context
        case .valueNotFound(_, let context): return context
        case .keyNotFound(_, let context): return context
        case .dataCorrupted(let context): return context
        }
    }

}
