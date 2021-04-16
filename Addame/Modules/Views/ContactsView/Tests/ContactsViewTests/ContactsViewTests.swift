import XCTest
@testable import ContactsView

final class ContactsViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ContactsView().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
