import XCTest
@testable import CoreDataClient

final class CoreDataClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CoreDataClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
