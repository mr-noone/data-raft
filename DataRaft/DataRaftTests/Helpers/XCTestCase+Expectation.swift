//
//  XCTestHelpers.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 16.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import XCTest

extension XCTestCase {
  func expectation(description: String = "", timeout seconds: TimeInterval = 30.0, closure: (XCTestExpectation) -> ()) {
    let expectation = XCTestExpectation(description: description)
    closure(expectation)
    wait(for: [expectation], timeout: seconds)
  }
}
