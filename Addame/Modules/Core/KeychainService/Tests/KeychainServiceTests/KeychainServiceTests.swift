import XCTest
@testable import KeychainService

final class KeychainServiceTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(KeychainService().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
