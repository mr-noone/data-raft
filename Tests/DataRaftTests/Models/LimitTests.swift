import XCTest
import DataRaft

class LimitTests: XCTestCase {
    func testDescription() {
        let limit1: Limit = 10
        let limit2: Limit = Limit(limit: 5, offset: 10)
        XCTAssertEqual(limit1.description, "LIMIT 10")
        XCTAssertEqual(limit2.description, "LIMIT 5 OFFSET 10")
    }
    
    func testInit() {
        let limit1 = Limit(limit: 10)
        let limit2 = Limit(limit: 5, offset: 10)
        XCTAssertEqual(limit1.limit, 10)
        XCTAssertNil(limit1.offset)
        XCTAssertEqual(limit2.limit, 5)
        XCTAssertEqual(limit2.offset, 10)
    }
    
    func testInitLiteral() {
        let limit: Limit = 10
        XCTAssertEqual(limit.limit, 10)
        XCTAssertNil(limit.offset)
    }
}
