import XCTest
import DataRaft
import SQLiteSwift

class ModelServiceTests: XCTestCase {
    struct TestModel: Model {
        var id: Int
        var name: String
    }
    
    var connection: Connection!
    var modelService: ModelService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        connection = try Connection(location: .inMemory, options: .readwrite)
        modelService = ModelService(connection: connection)
        let sql = """
        CREATE TABLE IF NOT EXISTS TestModel (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
        )
        """
        try connection.execute(sql: sql, args: [])
    }
    
    override func tearDownWithError() throws {
        connection = nil
        modelService = nil
        try super.tearDownWithError()
    }
    
    func testInsertAndSelect() {
        let model = TestModel(id: 1, name: "Test")
        XCTAssertNoThrow(try modelService.insert(model))
        XCTAssertNoThrow(try {
            let retrievedModels: [TestModel] = try modelService.select()
            XCTAssertEqual(retrievedModels.count, 1)
            XCTAssertEqual(retrievedModels.first?.id, 1)
            XCTAssertEqual(retrievedModels.first?.name, "Test")
        }())
    }
    
    func testExists() {
        let model = TestModel(id: 1, name: "Test")
        XCTAssertNoThrow(try modelService.insert(model))
        XCTAssertTrue(try modelService.exists(id: 1, of: TestModel.self))
        XCTAssertFalse(try modelService.exists(id: 2, of: TestModel.self))
    }
    
    func testCount() {
        let model1 = TestModel(id: 1, name: "Test")
        let model2 = TestModel(id: 2, name: "Test")
        let model3 = TestModel(id: 3, name: "Not")
        let predicate = Predicate(expression: "name = ?", "Test")
        XCTAssertNoThrow(try modelService.insert([model1, model2, model3]))
        XCTAssertEqual(try modelService.count(of: TestModel.self), 3)
        XCTAssertEqual(try modelService.count(predicate, of: TestModel.self), 2)
    }
    
    func testUpdate() {
        let model = TestModel(id: 1, name: "Test")
        let updatedModel = TestModel(id: 1, name: "Updated Test")
        XCTAssertNoThrow(try modelService.insert(model))
        XCTAssertNoThrow(try modelService.update(updatedModel))
        XCTAssertNoThrow(try {
            let retrievedModel: TestModel? = try modelService.select(id: 1)
            XCTAssertEqual(retrievedModel?.id, 1)
            XCTAssertEqual(retrievedModel?.name, "Updated Test")
        }())
    }
    
    func testDelete() {
        let model = TestModel(id: 1, name: "Test")
        XCTAssertNoThrow(try modelService.insert(model))
        XCTAssertNoThrow(try modelService.delete(model))
        XCTAssertNoThrow(try {
            let model: TestModel? = try modelService.select(id: 1)
            XCTAssertNil(model)
        }())
    }
}
