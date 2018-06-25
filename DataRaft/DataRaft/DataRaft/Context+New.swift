//
//  Context+New.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 22.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
  /// Creates a managed object and inserts it into that context.
  ///
  /// - Returns: The instance of object of the given type.
  public func new<T: NSManagedObject>() -> T {
    return NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as! T
  }
}
