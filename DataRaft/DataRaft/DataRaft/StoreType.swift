//
//  StoreType.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 15.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData

public enum StoreType {
  public typealias RawValue = String
  
  case inMemory
  case sqLite
  
  public var rawValue: RawValue {
    switch self {
    case .inMemory:
      return NSInMemoryStoreType
    default:
      return NSSQLiteStoreType
    }
  }
}
