import XCTest
@testable import Tabs

final class TabsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Tabs().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
