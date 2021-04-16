import XCTest
@testable import InfoPlist

final class InfoPlistTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(InfoPlist().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
