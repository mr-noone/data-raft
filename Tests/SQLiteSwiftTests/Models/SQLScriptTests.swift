import XCTest
import SQLiteSwift

class SQLScriptTests: XCTestCase {
    func testInitWithValidFile() throws {
        let sqlScript = try SQLScript(
            byResource: "sample_script",
            extension: "sql",
            in: .module
        )
        XCTAssertNotNil(sqlScript)
        XCTAssertEqual(sqlScript?.count, 2)
    }
    
    func testInitWithInvalidFile() throws {
        let sqlScript = try SQLScript(
            byResource: "invalid_script",
            extension: "sql",
            in: .module
        )
        XCTAssertNil(sqlScript)
    }
    
    func testAccessingStatements() throws {
        let sqlScript = try SQLScript(
            byResource: "sample_script",
            extension: "sql",
            in: .module
        )
        
        let oneStatement = """
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            email TEXT NOT NULL
        )
        """
        
        let twoStatement = """
        INSERT INTO users (id, username, email)
        VALUES
            (1, 'john_doe', 'john@example.com'),
            (2, 'jane_doe', 'jane@example.com')
        """
        
        XCTAssertEqual(sqlScript?[0], oneStatement)
        XCTAssertEqual(sqlScript?[1], twoStatement)
    }
}
