//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import XCTest
import AnyCodable
@testable import HttpResponseParser

final class PayloadParserTests: XCTestCase {
    
    private let expectedData = String.random().data(using: .utf8)!

    func test_whenPayloadIsDecoded_thenPayloadIsReturned() {
        let expectedPayload = PayloadMock.random()
        let parser = PayloadParser(decoder: jsonDecoder(with: .payload(expectedPayload)))
        let payload = try! parser.payload(from: expectedData) as PayloadMock
        XCTAssertEqual(payload, expectedPayload)
    }

    func test_whenErrorIsDecoded_thenAppropriateErrorIsThrown() {
        let expectedResponseError = ResponseError.failure(message: .random())
        let parser = PayloadParser(decoder: jsonDecoder(with: Response<PayloadMock>.error(expectedResponseError)))
        XCTAssertThrowsError(try parser.payload(from: expectedData) as PayloadMock, "Has to throw an error") { error in
            switch parserError(from: error) {
            case .requestFailed(let responseError):
                XCTAssertEqual(responseError, expectedResponseError)
            default:
                XCTFail("Unexpected error is thrown")
            }
        }
    }

    func test_whenDataIsNotPassed_thenAppropriateErrorIsThrown() {
        let parser = PayloadParser(decoder: jsonDecoder(throwing: MockError.some))
        XCTAssertThrowsError(try parser.payload(from: nil) as PayloadMock, "Has to throw an error") { error in
            switch parserError(from: error) {
            case .invalidData:
                // Expected error is thrown
                break
            default:
                XCTFail("Unexpected error is thrown")
            }
        }
    }

    func test_whenDecodingFailed_thenthenAppropriateErrorIsThrown() {
        let expectedDecodingError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: .random()))
        let parser = PayloadParser(decoder: jsonDecoder(throwing: expectedDecodingError))
        XCTAssertThrowsError(try parser.payload(from: expectedData) as PayloadMock, "Has to throw an error") { error in
            switch parserError(from: error) {
            case .decodingFailed(let decodingError):
                XCTAssertTrue(decodingError.isDataCorrupted)
                XCTAssertEqual(decodingError.context.debugDescription, expectedDecodingError.context.debugDescription)
            default:
                XCTFail("Unexpected error is thrown")
            }
        }
    }

    func test_whenDecodingFailedWithUnexpectedError_thenAppropriateErrorIsThrown() {
        let parser = PayloadParser(decoder: jsonDecoder(throwing: MockError.some))
        XCTAssertThrowsError(try parser.payload(from: expectedData) as PayloadMock, "Has to throw an error") { error in
            switch parserError(from: error) {
            case .other(let otherError):
                XCTAssertEqual(otherError as? MockError, MockError.some)
            default:
                XCTFail("Unexpected error is thrown")
            }
        }
    }

}

// MARK: Non-generic version
extension PayloadParserTests {
    
    func test_whenNonGenericVersionIsUsed_thenCorrectPayloadIsReturned() {
        let expectedPayload = PayloadMock.random()
        let parser = PayloadParser(decoder: jsonDecoder(with: .payload(AnyCodable(expectedPayload))))
        let payload = try! parser.payload(from: expectedData)
        XCTAssertEqual(payload as? PayloadMock, expectedPayload)
    }
    
    // Testing of error cases is redundant since throwing an error works the same way for both generic and non-generic versions
    
}

private extension PayloadParserTests {
    
    enum MockError: Error, Equatable { case some }
    
    func jsonDecoder<T>(with response: Response<T>, file: StaticString = #file, line: UInt = #line) -> JSONDecoderProtocol {
        return JSONDecoderMock<Response<T>> { data in
            XCTAssertEqual(data, self.expectedData, file: file, line: line)
            return response
        }
    }

    func jsonDecoder(throwing error: Error, file: StaticString = #file, line: UInt = #line) -> JSONDecoderProtocol {
        return JSONDecoderMock<Response<PayloadMock>> { data in
            XCTAssertEqual(data, self.expectedData, file: file, line: line)
            throw error
        }
    }

    func parserError(from error: Error, file: StaticString = #file, line: UInt = #line) -> PayloadParser.Error {
        guard let error = error as? PayloadParser.Error else {
            XCTFail("Expecting PayloadParser.Error", file: file, line: line)
            fatalError()
        }
        return error
    }
    
}
