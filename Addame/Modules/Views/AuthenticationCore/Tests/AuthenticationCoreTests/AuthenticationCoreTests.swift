import XCTest
@testable import AuthenticationCore

final class AuthenticationCoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AuthenticationCore().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
