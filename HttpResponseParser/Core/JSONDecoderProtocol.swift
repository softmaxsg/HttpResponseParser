//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

public protocol JSONDecoderProtocol {
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
    
}

extension JSONDecoder: JSONDecoderProtocol { }
