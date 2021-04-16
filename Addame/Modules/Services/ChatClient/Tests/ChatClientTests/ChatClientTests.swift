import XCTest
@testable import ChatClient

final class ChatClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ChatClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
