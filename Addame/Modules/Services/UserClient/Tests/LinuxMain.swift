import XCTest

import AddaMeModels ClientTests

var tests = [XCTestCaseEntry]()
tests += UserClientTests.allTests()
XCTMain(tests)
