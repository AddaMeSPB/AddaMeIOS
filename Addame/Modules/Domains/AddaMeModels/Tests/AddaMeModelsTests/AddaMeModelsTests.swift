import XCTest
@testable import AddaMeModels

final class AddaMeModelsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AddaMeModels().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
