//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

public final class PayloadParser {

    public enum Error: Swift.Error {
        case invalidData
        case requestFailed(ResponseError)
        case decodingFailed(DecodingError)
        case other(Swift.Error)
    }
    
    private let decoder: JSONDecoderProtocol
    
    public init(decoder: JSONDecoderProtocol = JSONDecoder()) {
        self.decoder = decoder
    }

    // Basically it makes sense to make the input parameter of `Data` type but assignment description says it has to be `Data?`
    public func payload<T>(from data: Data?) throws -> T where T: Decodable {
        guard let data = data else { throw Error.invalidData }

        do {
            let response = try decoder.decode(Response<T>.self, from: data)
            switch response {
            case .payload(let payload): return payload
            case .error(let error): throw error
            }
        } catch let error as ResponseError {
            throw Error.requestFailed(error)
        } catch let error as DecodingError {
            throw Error.decodingFailed(error)
        } catch {
            throw Error.other(error)
        }
    }
    
}

extension PayloadParser.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return errorDescription(key: "error.payloadparser.data.invalid")
        case .requestFailed(let error):
            return errorDescription(key: "error.payloadparser.request.failed", underlying: error)
        case .decodingFailed(let error):
            return errorDescription(key: "error.payloadparser.decoding.failed", underlying: error)
        case .other(let error):
            return errorDescription(key: "error.payloadparser.other", underlying: error)
        }
    }

}
