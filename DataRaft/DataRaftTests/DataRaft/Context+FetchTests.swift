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

@objc(Contact)
public class Contact: NSManagedObject, ManagedObject {
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var age: Int16
}

class Context_FetchTests: XCTestCase {
    let bundle = Bundle(for: DataRaft_PerformTests.self)
    var db: DataRaft!
    
    override func setUp() {
        super.setUp()
        db = DataRaft()
        try! db.configure(modelName: "Model", bundle: bundle)
        db.performAndWaitOnMain { context in
            for _ in 1...10 {
                NSEntityDescription.insertNewObject(forEntityName: Contact.entityName(), into: context)
            }
            try! context.save()
        }
    }
    
    override func tearDown() {
        db = nil
        super.tearDown()
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
