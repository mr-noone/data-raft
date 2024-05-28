import XCTest
import DataRaft

class PredicateTests: XCTestCase {
    func testInitWithVariadic() {
        let predicate = Predicate(expression: "name = ? AND age = ?", "John", 30)
        XCTAssertEqual(predicate.expression, "name = ? AND age = ?")
        XCTAssertEqual(predicate.arguments?.count, 2)
        XCTAssertEqual(predicate.arguments?[0].token, .indexed(index: 1))
        XCTAssertEqual(predicate.arguments?[0].value, .text("John"))
        XCTAssertEqual(predicate.arguments?[1].token, .indexed(index: 2))
        XCTAssertEqual(predicate.arguments?[1].value, .int(30))
    }
    
    func testInitWithArguments() {
        let predicate = Predicate(
            expression: "name = :name AND age = :age",
            ["name": "John", "age": 30]
        )
        XCTAssertEqual(predicate.expression, "name = :name AND age = :age")
        XCTAssertEqual(predicate.arguments?.count, 2)
        XCTAssertEqual(predicate.arguments?[0].token, .named(name: "name"))
        XCTAssertEqual(predicate.arguments?[0].value, .text("John"))
        XCTAssertEqual(predicate.arguments?[1].token, .named(name: "age"))
        XCTAssertEqual(predicate.arguments?[1].value, .int(30))
    }
    
    func testInitWithoutArguments() {
        let predicate = Predicate(expression: "name = 'John'")
        XCTAssertEqual(predicate.expression, "name = 'John'")
        XCTAssertNil(predicate.arguments)
    }
    
    func testDescription() {
        let predicate = Predicate(expression: "name = ? AND age = ?", "John", 30)
        XCTAssertEqual(predicate.description, "WHERE name = ? AND age = ?")
    }
}
