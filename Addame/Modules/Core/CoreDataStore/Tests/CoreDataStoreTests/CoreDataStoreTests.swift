import XCTest
@testable import CoreDataStore

final class CoreDataStoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CoreDataStore().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
