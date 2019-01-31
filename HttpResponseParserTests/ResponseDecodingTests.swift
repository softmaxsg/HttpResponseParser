//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import HttpResponseParser

final class ResponseDecodingTests: XCTestCase {
    
    private static let jsonResultKey = "result"
    private static let jsonPayloadKey = "payload"
    private static let jsonErrorMesageKey = "message"
    
    private let normalPayload = PayloadMock.random()
    private let errorWithMessage = ResponseError.failure(message: .random())
    private let unknownError = ResponseError.unknown

    private let decoder = JSONDecoder()

}

// MARK: Normal cases
extension ResponseDecodingTests {
    
    func test_whenSuccessfulResponse_thenPayloadReturned() {
        let responseData = jsonData(response: .payload(normalPayload))
        let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
        XCTAssertEqual(payload.payload, normalPayload)
    }
    
    func test_whenFailedResponse_thenErrorReturned() {
        let responseData = jsonData(response: .error(errorWithMessage))
        let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
        XCTAssertEqual(payload.error, errorWithMessage)
    }
    
    func test_whenFailedResponseWithoutErrorMesage_thenUnknownErrorReturned() {
        let responseData = jsonData(response: .error(unknownError))
        let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
        XCTAssertEqual(payload.error, unknownError)
    }

}

// MARK: Invalid payload
extension ResponseDecodingTests {

    func test_whenPayloadIsMissed_thenDecodingFails() {
        let responseData = invalidJsonData(payload: nil)
        XCTAssertThrowsError(try decoder.decode(Response<PayloadMock>.self, from: responseData), "Has to throw an error") { error in
            XCTAssertTrue((error as? DecodingError)?.isKeyNotFound ?? false)
        }
    }
    
    func test_whenPayloadIsNull_thenDecodingFails() {
        let responseData = invalidJsonData(payload: NSNull())
        XCTAssertThrowsError(try decoder.decode(Response<PayloadMock>.self, from: responseData), "Has to throw an error") { error in
            XCTAssertTrue((error as? DecodingError)?.isValueNotFound ?? false)
        }
    }

    func test_whenPayloadIsInvalid_thenDecodingFails() {
        let responseData = invalidJsonData(payload: String.random())
        XCTAssertThrowsError(try decoder.decode(Response<PayloadMock>.self, from: responseData), "Has to throw an error") { error in
            XCTAssertTrue((error as? DecodingError)?.isTypeMismatch ?? false)
        }
    }
    
}

// MARK: Invalid error mesage
extension ResponseDecodingTests {
    
    func test_whenErrorMessageIsInvalid_thenDecodingFails() {
        let responseData = invalidJsonData(errorMessage: Int.random(in: 0...Int.max))
        XCTAssertThrowsError(try decoder.decode(Response<PayloadMock>.self, from: responseData), "Has to throw an error") { error in
            XCTAssertTrue((error as? DecodingError)?.isTypeMismatch ?? false)
        }
    }
    
}

// MARK: Result variations
extension ResponseDecodingTests {
    
    func test_whenResultIsPositiveInteger_thenDecodedAsTrue() {
        let responseData = jsonData(
            result: Int.random(in: 1..<Int.max),
            payload: normalPayload.json,
            error: nil
        )

        let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
        XCTAssertEqual(payload.payload, normalPayload)

    }
    
    func test_whenResultIsNegativeInteger_thenDecodedAsTrue() {
        let responseData = jsonData(
            result: Int.random(in: Int.min..<0),
            payload: normalPayload.json,
            error: nil
        )
        
        let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
        XCTAssertEqual(payload.payload, normalPayload)
        
    }

    func test_whenResultIsZero_thenDecodedAsFalse() {
        let responseData = jsonData(
            result: 0,
            payload: nil,
            error: errorWithMessage.message
        )

        let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
        XCTAssertEqual(payload.error, errorWithMessage)
    }

    private var trueCharacters: String { return "YyTt123456789" }
    private var falseCharacters: String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".filter { !trueCharacters.contains($0) } }

    func test_whenResultIsStringStartsWithTrueChars_thenDecodedAsTrue() {
        for character in trueCharacters {
            let responseData = jsonData(
                result: "\(character)\(String.random())",
                payload: normalPayload.json,
                error: nil
            )
            
            let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
            XCTAssertEqual(payload.payload, normalPayload)
        }
    }
    
    func test_whenResultIsStringDoesNotStartWithTrueChars_thenDecodedAsFalse() {
        let responseData = jsonData(
            result: "\(falseCharacters.randomElement()!)\(String.random())",
            payload: nil,
            error: errorWithMessage.message
        )
        
        let payload = try! decoder.decode(Response<PayloadMock>.self, from: responseData)
        XCTAssertEqual(payload.error, errorWithMessage)
    }

    func test_whenResultIsMissed_thenDecodingFails() {
        let responseData = invalidJsonData(result: nil)
        XCTAssertThrowsError(try decoder.decode(Response<PayloadMock>.self, from: responseData), "Has to throw an error") { error in
            XCTAssertTrue((error as? DecodingError)?.isKeyNotFound ?? false)
        }
    }

    func test_whenResultIsNull_thenDecodingFails() {
        let responseData = invalidJsonData(result: NSNull())
        XCTAssertThrowsError(try decoder.decode(Response<PayloadMock>.self, from: responseData), "Has to throw an error") { error in
            XCTAssertTrue((error as? DecodingError)?.isValueNotFound ?? false)
        }
    }

    func test_whenResultIsInvalid_thenDecodingFails() {
        let responseData = invalidJsonData(result: Double.random(in: 0..<Double.greatestFiniteMagnitude))
        XCTAssertThrowsError(try decoder.decode(Response<PayloadMock>.self, from: responseData), "Has to throw an error") { error in
            XCTAssertTrue((error as? DecodingError)?.isTypeMismatch ?? false)
        }
    }

}

private extension ResponseDecodingTests {

    func jsonData(result: Any?, payload: Any?, error: Any?) -> Data {
        var json: [String: Any] = [:]
        json[ResponseDecodingTests.jsonResultKey] = result
        json[ResponseDecodingTests.jsonPayloadKey] = payload
        json[ResponseDecodingTests.jsonErrorMesageKey] = error
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func jsonData(response: Response<PayloadMock>) -> Data {
        return jsonData(
            result: response.payload != nil,
            payload: response.payload?.json,
            error: response.error?.message
        )
    }

    func invalidJsonData(payload: Any?) -> Data {
        return jsonData(
            result: true,
            payload: payload,
            error: nil
        )
    }

    func invalidJsonData(errorMessage: Any?) -> Data {
        return jsonData(
            result: false,
            payload: nil,
            error: errorMessage
        )
    }

    func invalidJsonData(result: Any?) -> Data {
        return jsonData(
            result: result,
            payload: nil,
            error: nil
        )
    }

}
