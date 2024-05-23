import XCTest
import DataRaft

class OrderByTests: XCTestCase {
    func testSortOrderDescription() {
        XCTAssertEqual(OrderBy.SortOrder.ascending.description, "ASC")
        XCTAssertEqual(OrderBy.SortOrder.descending.description, "DESC")
    }
    
    func testNullPlacementDescription() {
        XCTAssertEqual(OrderBy.NullPlacement.first.description, "NULLS FIRST")
        XCTAssertEqual(OrderBy.NullPlacement.last.description, "NULLS LAST")
    }
    
    func testSortDescriptorDescription() {
        let sortDescriptor1 = OrderBy.SortDescriptor(
            column: "name",
            sortOrder: .ascending
        )
        let sortDescriptor2 = OrderBy.SortDescriptor(
            column: "age",
            sortOrder: .descending,
            nullPlacement: .last
        )
        XCTAssertEqual(sortDescriptor1.description, "name ASC")
        XCTAssertEqual(sortDescriptor2.description, "age DESC NULLS LAST")
    }
    
    func testSortDescriptorInit() {
        let sortDescriptor = OrderBy.SortDescriptor(
            column: "name",
            sortOrder: .ascending
        )
        XCTAssertEqual(sortDescriptor.column, "name")
        XCTAssertEqual(sortDescriptor.sortOrder, .ascending)
        XCTAssertNil(sortDescriptor.nullPlacement)
    }
    
    func testSortDescriptorInitWithWhitespacesAndNewlines() {
        let sortDescriptor = OrderBy.SortDescriptor(
            column: " \n name \n"
        )
        XCTAssertEqual(sortDescriptor.column, "name")
    }
    
    func testOrderByDescription() {
        let orderBy: OrderBy = [
            .init(column: "name", sortOrder: .ascending),
            .init(column: "age", sortOrder: .descending, nullPlacement: .last)
        ]
        XCTAssertEqual(orderBy.description, "ORDER BY name ASC, age DESC NULLS LAST")
    }
    
    func testOrderByInit() {
        let orderBy: OrderBy = [
            .init(column: "name", sortOrder: .ascending),
            .init(column: "age", sortOrder: .descending, nullPlacement: .last)
        ]
        XCTAssertEqual(orderBy.descriptors.count, 2)
    }
    
    func testOrderByInitWithEmptyColumn() {
        let orderBy: OrderBy = [
            .init(column: "", sortOrder: .ascending, nullPlacement: .last),
        ]
        XCTAssertEqual(orderBy.descriptors.count, 0)
    }
}
