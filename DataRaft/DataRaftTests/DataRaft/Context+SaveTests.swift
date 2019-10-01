//
//  Context+Save.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 18.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import XCTest
import CoreData
@testable import DataRaft

class Context_SaveTests: XCTestCase {
  let bundle = Bundle(for: Context_SaveTests.self)
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
  
  func testSaveToStore() {
    db.performAndWaitOnPrivate { context in
      NSEntityDescription.insertNewObject(forEntityName: Contact.entityName, into: context)
      try! context.saveToStore()
    }
    
    db.performAndWaitOnMain { context in
      let contacts: [Contact] = try! context.fetch()
      XCTAssertNotNil(contacts.first)
    }
  }
}
