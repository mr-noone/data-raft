import XCTest
import SQLiteSwift

class StatementArgumentsTests: XCTestCase {
    func testInitFromArrayLiteral() {
        let args: Statement.Arguments = ["John", 30]
        XCTAssertEqual(args.count, 2)
        XCTAssertEqual(args[0].token, .indexed(index: 1))
        XCTAssertEqual(args[0].value, .text("John"))
        XCTAssertEqual(args[1].token, .indexed(index: 2))
        XCTAssertEqual(args[1].value, .int(30))
    }
    
    func testInitFromDictionaryLiteral() {
        let args: Statement.Arguments = ["name": "John", "age": 30]
        XCTAssertEqual(args.count, 2)
        XCTAssertEqual(args[0].token, .named(name: "name"))
        XCTAssertEqual(args[0].value, .text("John"))
        XCTAssertEqual(args[1].token, .named(name: "age"))
        XCTAssertEqual(args[1].value, .int(30))
    }
    
    func testConcatenation() {
        var args1: Statement.Arguments = ["name": "John"]
        let args2: Statement.Arguments = ["age": 30]
        args1 += args2
        XCTAssertEqual(args1.count, 2)
        XCTAssertEqual(args1[0].token, .named(name: "name"))
        XCTAssertEqual(args1[0].value, .text("John"))
        XCTAssertEqual(args1[1].token, .named(name: "age"))
        XCTAssertEqual(args1[1].value, .int(30))
    }
    
    func testMerging() {
        let args1: Statement.Arguments = ["name": "John"]
        let args2: Statement.Arguments = ["name": "Jane"]
        let mergedArgs = args1 &+ args2
        XCTAssertEqual(mergedArgs.count, 1)
        XCTAssertEqual(mergedArgs[0].token, .named(name: "name"))
        XCTAssertEqual(mergedArgs[0].value, .text("Jane"))
    }
    
    func testMixedArgumens() {
        var args1: Statement.Arguments = ["name": "John"]
        let args2: Statement.Arguments = [30]
        args1 += args2
        XCTAssertEqual(args1[0].token, .named(name: "name"))
        XCTAssertEqual(args1[0].value, .text("John"))
        XCTAssertEqual(args1[1].token, .indexed(index: 2))
        XCTAssertEqual(args1[1].value, .int(30))
    }
}
