import XCTest
import SQLighter
@testable import DataRaft

private enum RecordKeys: CodingKey, SQLColumn {
  case key_1
  case key_2
  case key_3
}

final class RecordEncodingContainerTests: XCTestCase {
  private var encoder: RecordEncoder!
  private var container: KeyedEncodingContainer<RecordKeys>!
  
  override func setUp() {
    super.setUp()
    encoder = RecordEncoder()
    container = encoder.container(keyedBy: RecordKeys.self)
  }
  
  override func tearDown() {
    encoder = nil
    container = nil
    super.tearDown()
  }
  
  func testEncodeNil() {
    try! container.encodeNil(forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.null)
  }
  
  func testEncodeBool() {
    try! container.encode(true, forKey: .key_1)
    try! container.encode(false, forKey: .key_2)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(1))
    XCTAssertEqual(encoder.record[RecordKeys.key_2], SQLValue.int(0))
  }
  
  func testEncodeString() {
    try! container.encode("str", forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.text("str"))
  }
  
  func testEncodeDouble() {
    try! container.encode(Double(3.14), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.real(3.14))
  }
  
  func testEncodeFloat() {
    try! container.encode(Float(1), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.real(1))
  }
  
  func testEncodeInt() {
    try! container.encode(Int(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeInt8() {
    try! container.encode(Int8(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeInt16() {
    try! container.encode(Int16(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeInt32() {
    try! container.encode(Int32(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeInt64() {
    try! container.encode(Int64(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeUInt() {
    try! container.encode(UInt(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeUInt8() {
    try! container.encode(UInt8(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeUInt16() {
    try! container.encode(UInt16(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeUInt32() {
    try! container.encode(UInt32(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeUInt64() {
    try! container.encode(UInt64(123), forKey: .key_1)
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.int(123))
  }
  
  func testEncodeEncodable() {
    class Test: Encodable {}
    
    let uuid = UUID()
    
    try XCTAssertNoThrow(container.encode(uuid, forKey: .key_1))
    try XCTAssertThrowsError(container.encode(Test(), forKey: .key_2))
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.text(uuid.uuidString))
  }
  
  func testEncodeIfPresent() {
    let value_1: Bool? = nil
    let value_2: Bool? = true
    try! container.encodeIfPresent(value_1, forKey: .key_1)
    try! container.encodeIfPresent(value_2, forKey: .key_2)
    
    XCTAssertEqual(encoder.record[RecordKeys.key_1], SQLValue.null)
    XCTAssertEqual(encoder.record[RecordKeys.key_2], SQLValue.int(1))
  }
}
