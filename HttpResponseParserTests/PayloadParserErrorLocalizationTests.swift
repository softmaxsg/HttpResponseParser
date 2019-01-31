//
//  Copyright © 2019 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import HttpResponseParser

final class PayloadParserErrorLocalizationTests: XCTestCase {

    private let bundle = Bundle(for: PayloadParser.self)
    
    func test_whenInvalidData_thenAppropriateDescriptionIsReturned() {
        let expectedDescription = localizedString("error.payloadparser.data.invalid")
        let errorDescription = PayloadParser.Error.invalidData.localizedDescription
        XCTAssertEqual(errorDescription, expectedDescription)
    }
    
    func test_whenRequestFailedWithMessage_thenAppropriateDescriptionIsReturned() {
        let error = ResponseError.failure(message: .random())
        let expectedDescription = "\(localizedString("error.payloadparser.request.failed")) \(error.message!)"
        let errorDescription = PayloadParser.Error.requestFailed(error).localizedDescription
        XCTAssertEqual(errorDescription, expectedDescription)
    }
    
    func test_whenRequestFailedWithoutMessage_thenAppropriateDescriptionIsReturned() {
        let expectedDescription = "\(localizedString("error.payloadparser.request.failed")) \(localizedString("error.response.error.unknown"))"
        let errorDescription = PayloadParser.Error.requestFailed(ResponseError.unknown).localizedDescription
        XCTAssertEqual(errorDescription, expectedDescription)
    }
    
    func test_whenDecodingFailed_thenAppropriateDescriptionIsReturned() {
        let error = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: .random()))
        let expectedDescription = "\(localizedString("error.payloadparser.decoding.failed")) \(error.localizedDescription)"
        let errorDescription = PayloadParser.Error.decodingFailed(error).localizedDescription
        XCTAssertEqual(errorDescription, expectedDescription)
    }
    
    func test_whenDecodingFailedWithUnexpectedError_thenAppropriateDescriptionIsReturned() {
        let error = MockError.some
        let expectedDescription = "\(localizedString("error.payloadparser.other")) \(error.localizedDescription)"
        let errorDescription = PayloadParser.Error.other(error).localizedDescription
        XCTAssertEqual(errorDescription, expectedDescription)
    }

}

private extension PayloadParserErrorLocalizationTests {
    
    enum MockError: Error { case some }

    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
