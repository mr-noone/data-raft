//
//  URL+StoreHelpersTests.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 17.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import XCTest
@testable import DataRaft

class URL_StoreHelpersTests: XCTestCase {
    let bundle = Bundle(for: URL_StoreHelpersTests.self)
    
    func testStoreUrl() {
        let storeUrl = URL(storeURLWithPath: "path/to/store", modelName: "model", in: bundle)
        XCTAssertEqual(storeUrl, URL(fileURLWithPath: "path/to/store/model.sqlite"), "Objects must by equal.")
    }
    
    func testStoreUrlWithNilPath() {
        let storeUrl = URL(storeURLWithPath: nil, modelName: "model", in: bundle)
        
        var controlUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        controlUrl?.appendPathComponent(bundle.bundleIdentifier!, isDirectory: true)
        controlUrl?.appendPathComponent("model")
        controlUrl?.appendPathExtension("sqlite")
        
        XCTAssertEqual(storeUrl, controlUrl, "Objects must by equal.")
    }
    
    func testStoreUrlWithNilPathAndNilBundleId() {
        let storeUrl = URL(storeURLWithPath: nil, modelName: "model", in: .main)
        
        var controlUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        controlUrl?.appendPathComponent("DB", isDirectory: true)
        controlUrl?.appendPathComponent("model")
        controlUrl?.appendPathExtension("sqlite")
        
        XCTAssertEqual(storeUrl, controlUrl, "Objects must by equal.")
    }
    
    func testFileUrlWithUrl() {
        let url = URL(fileURLWithPath: "test/apth")
        let fileUrl = URL(fileURLWithURL: url)
        XCTAssertEqual(fileUrl, url, "Objects must by equal.")
    }
    
    func testFileUrlWithNilUrl() {
        XCTAssertNil(URL(fileURLWithURL: nil), "The function must return nil if you pass nil url.")
    }
}
