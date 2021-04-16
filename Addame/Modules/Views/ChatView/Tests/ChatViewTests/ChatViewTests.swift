import XCTest
@testable import ChatView

final class ChatViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ChatView().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
