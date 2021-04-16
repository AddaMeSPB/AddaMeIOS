import XCTest
@testable import ConversationClient

final class ConversationClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ConversationClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
