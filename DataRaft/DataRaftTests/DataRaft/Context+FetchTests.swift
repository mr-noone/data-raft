//
//  NSManagedObjectContext+FetchTests.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 18.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import XCTest
import CoreData
@testable import DataRaft

class Context_FetchTests: XCTestCase {
    let bundle = Bundle(for: Context_FetchTests.self)
    var db: DataRaft!
    
    override func setUp() {
        super.setUp()
        db = DataRaft()
        try! db.configure(modelName: "Model", bundle: bundle)
        db.performAndWaitOnMain { context in
            for _ in 1...10 {
                NSEntityDescription.insertNewObject(forEntityName: Contact.entityName, into: context)
            }
            try! context.save()
        }
    }
    
    override func tearDown() {
        db = nil
        super.tearDown()
    }
    
    func testObjectWithObjectID() {
        var objectID: NSManagedObjectID!
        
        db.performAndWaitOnPrivate { context in
            let contact = NSEntityDescription.insertNewObject(forEntityName: Contact.entityName, into: context)
            objectID = contact.objectID
        }
        
        db.performAndWaitOnMain { context in
            let contact: Contact = context.object(with: objectID)
            XCTAssertNotNil(contact, "Must not be nil")
        }
    }
    
    func testFetch() {
        db.performAndWaitOnMain { context in
            let contacts: [Contact] = try! context.fetch(predicate: nil, sortedBy: nil, ascending: true)
            XCTAssertTrue(contacts.count > 0)
        }
    }
    
    func testCount() {
        db.performAndWaitOnMain { context in
            let contactsCount = try! context.count(of: Contact.self, predicate: nil, sortedBy: nil, ascending: true)
            XCTAssertTrue(contactsCount > 0)
        }
    }
}
