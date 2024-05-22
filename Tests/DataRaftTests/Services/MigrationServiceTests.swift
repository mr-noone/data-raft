import XCTest
import SQLiteSwift
@testable import DataRaft

class MigrationServiceTests: XCTestCase {
    var connection: Connection!
    var migrationService: MigrationService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        connection = try Connection(location: .inMemory, options: .readwrite)
        migrationService = MigrationService(connection: connection)
    }
    
    override func tearDownWithError() throws {
        migrationService = nil
        connection = nil
        try super.tearDownWithError()
    }
    
    func testAddMigration() throws {
        let migration1 = Migration(version: 1, byResource: "migration_1", extension: "sql", in: .module)!
        let migration2 = Migration(version: 2, byResource: "migration_2", extension: "sql", in: .module)!
        let migration3 = Migration(version: 3, byResource: "migration_2", extension: "sql", in: .module)!
        
        XCTAssertNoThrow(try migrationService.add(migration1))
        XCTAssertNoThrow(try migrationService.add(migration2))
        XCTAssertThrowsError(try migrationService.add(migration3)) { error in
            switch error {
            case let MigrationService.Error.duplicateMigration(version, url):
                XCTAssertEqual(migration3.version, version)
                XCTAssertEqual(migration3.scriptURL, url)
            default:
                XCTFail("Unexpected error type")
            }
        }
    }
    
    func testMigrate() throws {
        let migration1 = Migration(version: 1, byResource: "migration_1", extension: "sql", in: .module)!
        let migration2 = Migration(version: 2, byResource: "migration_2", extension: "sql", in: .module)!
        try migrationService.add(migration1)
        try migrationService.add(migration2)
        try migrationService.migrate()
        XCTAssertEqual(connection.userVersion, 2)
    }
    
    func testMigrateWithError() throws {
        let migration3 = Migration(version: 3, byResource: "migration_3", extension: "sql", in: .module)!
        try migrationService.add(migration3)
        
        XCTAssertThrowsError(try migrationService.migrate()) { error in
            switch error {
            case let MigrationService.Error.migrationFailed(version, url, _):
                XCTAssertEqual(migration3.version, version)
                XCTAssertEqual(migration3.scriptURL, url)
            default:
                XCTFail("Unexpected error type")
            }
        }
        XCTAssertEqual(connection.userVersion, 0)
    }
}
