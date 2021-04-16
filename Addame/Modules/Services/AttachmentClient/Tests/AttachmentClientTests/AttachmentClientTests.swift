import XCTest
@testable import AttachmentClient

final class AttachmentClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AttachmentClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
