//
//  DataRaft+Perform.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 17.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData

extension DataRaft {
  // MARK: Public
  
  /// Asynchronously performs a given closure on the main context’s queue.
  ///
  /// - Parameters:
  ///   - closure: The closure to perform.
  /// - Parameters:
  ///   - context: Context where provided closure execute.
  public func performOnMain(_ closure: @escaping (_ context: NSManagedObjectContext) -> ()) {
    perform(on: self.main(), in: closure)
  }
  
  /// Synchronously performs a given closure on the main context’s queue.
  ///
  /// - Parameters:
  ///   - closure: The closure to perform.
  /// - Parameters:
  ///   - context: Context where provided closure execute.
  public func performAndWaitOnMain(_ closure: @escaping (_ context: NSManagedObjectContext) -> ()) {
    performAndWait(on: self.main(), in: closure)
  }
  
  /// Asynchronously performs a given closure on the new private context’s queue.
  ///
  /// - Parameters:
  ///   - closure: The closure to perform.
  /// - Parameters:
  ///   - context: Context where provided closure execute.
  public func performOnPrivate(_ closure: @escaping (_ context: NSManagedObjectContext) -> ()) {
    perform(on: self.private(), in: closure)
  }
  
  /// Synchronously performs a given closure on the new private context’s queue.
  ///
  /// - Parameters:
  ///   - closure: The closure to perform.
  /// - Parameters:
  ///   - context: Context where provided closure execute.
  public func performAndWaitOnPrivate(_ closure: @escaping (_ context: NSManagedObjectContext) -> ()) {
    performAndWait(on: self.private(), in: closure)
  }
  
  // MARK: Private
  
  private func perform(on context: NSManagedObjectContext, in closure: @escaping (NSManagedObjectContext) -> ()) {
    context.perform {
      closure(context)
    }
  }
  
  private func performAndWait(on context: NSManagedObjectContext, in closure: @escaping (NSManagedObjectContext) -> ()) {
    context.performAndWait {
      closure(context)
    }
  }
}
