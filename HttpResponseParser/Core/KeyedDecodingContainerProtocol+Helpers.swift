//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import Foundation

extension KeyedDecodingContainerProtocol {

    /// Decodes boolean value for the given key.
    ///
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: Boolean value of the requested type, if present for the given key
    ///   and convertible to Bool
    ///   or Int (returns true if not equal to 0)
    ///   or String (returns result of boolValue from NSString).
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry
    ///   for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for
    ///   the given key.
    public func decodeBool(forKey key: Self.Key) throws -> Bool {
        // DecodingError.keyNotFound will be thrown by decodeNil if key is not found
        guard !(try decodeNil(forKey: key)) else {
            throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(codingPath: [key], debugDescription: "Value for key \(key.stringValue) is null"))
        }
        
        if let boolValue = try? decode(Bool.self, forKey: key) { return boolValue }
        if let intValue = try? decode(Int.self, forKey: key) { return intValue != 0 }
        if let stringValue = try? decode(String.self, forKey: key) { return (stringValue as NSString).boolValue }

        throw DecodingError.typeMismatch(Bool.self, DecodingError.Context(codingPath: [key], debugDescription: "Value for key \(key.stringValue) can not be converted to Bool"))
    }

}
