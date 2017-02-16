import XCTest
@testable import FluentVapor

class FluentVaporTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        XCTAssertEqual(FluentVapor().text, "Hello, World!")
    }


    static var allTests : [(String, (FluentVaporTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
