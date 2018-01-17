//
//  DataRaftTests.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 16.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import XCTest
@testable import DataRaft

class DataRaftTests: XCTestCase {
    let bundle = Bundle(for: DataRaftTests.self)
    
    func testConfigureSQLite() {
        var error: Error? = nil
        do {
            try DataRaft().configure(type: .sqLite, modelName: "Model", bundle: bundle)
        } catch let err {
            error = err
        }
        XCTAssertNil(error)
    }
    
    func testConfigureInMemory() {
        var error: Error? = nil
        do {
            try DataRaft().configure(type: .inMemory, modelName: "Model", bundle: bundle)
        } catch let err {
            error = err
        }
        XCTAssertNil(error)
    }
    
    func testConfigureAsync() {
        expectation { expectation in
            DataRaft().configureAsync(modelName: "Model", bundle: bundle) { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
    }
    
    func testConfigureAsyncWithError() {
        expectation { expectation in
            DataRaft().configureAsync(modelName: "", bundle: bundle) { error in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
    }
    
    func testConfigureWithEmptyModelName() {
        var error: DataRaftError? = nil
        do {
            try DataRaft().configure(modelName: "")
        } catch let err {
            error = err as? DataRaftError
        }
        XCTAssertEqual(error, DataRaftError.ObjectModelNotFound, "Method must throw error if you pass empty model name.")
    }
    
    func testConfigureWithNotExistModel() {
        var error: DataRaftError? = nil
        do {
            try DataRaft().configure(modelName: "NotExistModel")
        } catch let err {
            error = err as? DataRaftError
        }
        XCTAssertEqual(error, DataRaftError.ObjectModelNotFound, "Method must throw error if model with name not exists")
    }
}
