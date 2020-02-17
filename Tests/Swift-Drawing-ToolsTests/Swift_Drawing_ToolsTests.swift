import XCTest
@testable import Swift_Drawing_Tools

final class Swift_Drawing_ToolsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Swift_Drawing_Tools().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
