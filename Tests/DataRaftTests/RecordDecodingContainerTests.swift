import XCTest
@testable import DataRaft

private enum RecordKeys: CodingKey {
  case key_1
  case key_2
  case key_3
}

final class RecordDecodingContainerTests: XCTestCase {
  private var container: RecordDecodingContainer<RecordKeys>!
  private var record: Record!
  
  override func setUp() {
    super.setUp()
    record = Record()
  }
  
  override func tearDown() {
    record = nil
    container = nil
    super.tearDown()
  }
  
  func testContainsKey() {
    record[RecordKeys.key_1.stringValue] = .int(0)
    container = .init(record: record)
    XCTAssertTrue(container.contains(.key_1))
    XCTAssertFalse(container.contains(.key_2))
  }
  
  func testDecodeNil() {
    record[RecordKeys.key_1.stringValue] = .null
    record[RecordKeys.key_2.stringValue] = .int(0)
    container = .init(record: record)
    try XCTAssertTrue(container.decodeNil(forKey: .key_1))
    try XCTAssertFalse(container.decodeNil(forKey: .key_2))
  }
  
  func testDecodeBool() {
    record[RecordKeys.key_1.stringValue] = .int(1)
    record[RecordKeys.key_2.stringValue] = .int(2)
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Bool.self, forKey: .key_1), true)
    try XCTAssertThrowsError(container.decode(Bool.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Bool.self, forKey: .key_3))
  }
  
  func testDecodeString() {
    record[RecordKeys.key_1.stringValue] = .text("str")
    record[RecordKeys.key_2.stringValue] = .int(123)
    container = .init(record: record)
    try XCTAssertEqual(container.decode(String.self, forKey: .key_1), "str")
    try XCTAssertThrowsError(container.decode(String.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(String.self, forKey: .key_3))
  }
  
  func testDecodeDouble() {
    record[RecordKeys.key_1.stringValue] = .real(3.14)
    record[RecordKeys.key_2.stringValue] = .int(123)
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Double.self, forKey: .key_1), 3.14)
    try XCTAssertThrowsError(container.decode(Double.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Double.self, forKey: .key_3))
  }
  
  func testDecodeFloat() {
    record[RecordKeys.key_1.stringValue] = .real(3.14)
    record[RecordKeys.key_2.stringValue] = .int(123)
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Float.self, forKey: .key_1), 3.14)
    try XCTAssertThrowsError(container.decode(Float.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Float.self, forKey: .key_3))
  }
  
  func testDecodeInt() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Int.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(Int.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Int.self, forKey: .key_3))
  }
  
  func testDecodeInt8() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Int8.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(Int8.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Int8.self, forKey: .key_3))
  }
  
  func testDecodeInt16() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Int16.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(Int16.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Int16.self, forKey: .key_3))
  }
  
  func testDecodeInt32() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Int32.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(Int32.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Int32.self, forKey: .key_3))
  }
  
  func testDecodeInt64() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(Int64.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(Int64.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(Int64.self, forKey: .key_3))
  }
  
  func testDecodeUInt() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(UInt.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(UInt.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(UInt.self, forKey: .key_3))
  }
  
  func testDecodeUInt8() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(UInt8.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(UInt8.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(UInt8.self, forKey: .key_3))
  }
  
  func testDecodeUInt16() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(UInt16.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(UInt16.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(UInt16.self, forKey: .key_3))
  }
  
  func testDecodeUInt32() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(UInt32.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(UInt32.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(UInt32.self, forKey: .key_3))
  }
  
  func testDecodeUInt64() {
    record[RecordKeys.key_1.stringValue] = .int(123)
    record[RecordKeys.key_2.stringValue] = .text("123")
    container = .init(record: record)
    try XCTAssertEqual(container.decode(UInt64.self, forKey: .key_1), 123)
    try XCTAssertThrowsError(container.decode(UInt64.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(UInt64.self, forKey: .key_3))
  }
  
  func testDecodeDecodable() {
    let uuid = UUID()
    
    class Test: Decodable {}
    
    record[RecordKeys.key_1.stringValue] = .text(uuid.uuidString)
    record[RecordKeys.key_2.stringValue] = .int(0)
    container = .init(record: record)
    
    try XCTAssertEqual(container.decode(UUID.self, forKey: .key_1), uuid)
    try XCTAssertThrowsError(container.decode(Test.self, forKey: .key_1))
    try XCTAssertThrowsError(container.decode(UUID.self, forKey: .key_2))
    try XCTAssertThrowsError(container.decode(UUID.self, forKey: .key_3))
  }
}
