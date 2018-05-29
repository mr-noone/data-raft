//
//  DataRaft+PerformTests.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 17.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import XCTest
import CoreData
@testable import DataRaft

class DataRaft_PerformTests: XCTestCase {
    let bundle = Bundle(for: DataRaft_PerformTests.self)
    var db: DataRaft!
    
    override func setUp() {
        super.setUp()
        db = DataRaft()
        try! db.configure(modelName: "Model", bundle: bundle)
    }
    
    override func tearDown() {
        db = nil
        super.tearDown()
    }
    
    func testPerformOnMain() {
        expectation { expectation in
            db.performOnMain { context in
                XCTAssertEqual(context, self.db.main(), "Objects must by equal.")
                XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType, "Objects must by equal.")
                expectation.fulfill()
            }
        }
    }
    
    func testPerformAndWaitOnMain() {
        var context: NSManagedObjectContext? = nil
        
        db.performAndWaitOnMain { aContext in
            context = aContext
        }
        
        XCTAssertEqual(context, self.db.main(), "Objects must by equal.")
        XCTAssertEqual(context?.concurrencyType, .mainQueueConcurrencyType, "Objects must by equal.")
    }
    
    func testPerformOnPrivate() {
        expectation { expectation in
            db.performOnPrivate { context in
                XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType, "Objects must by equal.")
                expectation.fulfill()
            }
        }
    }
    
    func testPerformAndWaitOnPrivate() {
        var context: NSManagedObjectContext? = nil
        
        db.performAndWaitOnPrivate { aContext in
            context = aContext
        }
        
        XCTAssertEqual(context?.concurrencyType, .privateQueueConcurrencyType, "Objects must by equal.")
    }
}
