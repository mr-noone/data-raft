//
//  Context+NewTests.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 22.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import XCTest
@testable import DataRaft

class Context_NewTests: XCTestCase {
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
  
  func testNewObject() {
    db.performAndWaitOnMain { context in
      let contact: Contact = context.new()
      XCTAssertNotNil(contact)
    }
  }
}
