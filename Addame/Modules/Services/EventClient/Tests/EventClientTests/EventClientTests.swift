import XCTest
@testable import EventClient

final class EventClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(EventClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
