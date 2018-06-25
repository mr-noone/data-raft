//
//  NSManagedObjectContext+Fetch.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 18.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
  /// Returns an array of objects that meet the criteria specified by a given predicate and sort descriptors.
  ///
  /// - Parameters:
  ///   - predicate: The predicate of the fetch request.
  ///   - sortDescriptors: The sort descriptors of the fetch request.
  /// - Returns: Returns an array of objects that meet the criteria specified by a given predicate and sort descriptors.
  /// - Throws: Throws error if there is a problem executing the fetch.
  public func fetch<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [T] {
    let request = NSFetchRequest<T>(entityName: T.entityName)
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    return try fetch(request)
  }
  
  /// Returns an array of objects that meet the criteria specified by a given predicate and sort descriptor.
  ///
  /// - Parameters:
  ///   - predicate: The predicate of the fetch request.
  ///   - sortedBy: The key path to use when performing a comparison.
  ///   - ascending: true if the receiver specifies sorting in ascending order, otherwise false.
  /// - Returns: Returns an array of objects that meet the criteria specified by a given predicate and sort descriptor.
  /// - Throws: Throws error if there is a problem executing the fetch.
  public func fetch<T: NSManagedObject>(predicate: NSPredicate? = nil, sortedBy: String? = nil, ascending: Bool = true) throws -> [T] {
    var sortDescriptors = [NSSortDescriptor]()
    if let sortedBy = sortedBy {
      sortDescriptors.append(NSSortDescriptor(key: sortedBy, ascending: ascending))
    }
    return try fetch(predicate: predicate, sortDescriptors: sortDescriptors)
  }
  
  /// Returns the number of objects a given predicate and sort descriptors would have returned.
  ///
  /// - Parameters:
  ///   - type: The type of object to fetch.
  ///   - predicate: The predicate of the fetch request.
  ///   - sortDescriptors: The sort descriptors of the fetch request.
  /// - Returns: Returns the number of objects a given predicate and sort descriptor would have returned.
  /// - Throws: Throws error if there is a problem executing the fetch.
  public func count<T: NSManagedObject>(of type: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> Int {
    let request = NSFetchRequest<T>(entityName: T.entityName)
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    request.resultType = .countResultType
    return try count(for: request)
  }
  
  /// Returns the number of objects a given predicate and sort descriptor would have returned.
  ///
  /// - Parameters:
  ///   - type: The type of object to fetch.
  ///   - predicate: The predicate of the fetch request.
  ///   - sortedBy: The key path to use when performing a comparison.
  ///   - ascending: true if the receiver specifies sorting in ascending order, otherwise false.
  /// - Returns: Returns the number of objects a given predicate and sort descriptor would have returned.
  /// - Throws: Throws error if there is a problem executing the fetch.
  public func count<T: NSManagedObject>(of type: T.Type, predicate: NSPredicate? = nil, sortedBy: String? = nil, ascending: Bool = true) throws -> Int {
    var sortDescriptors = [NSSortDescriptor]()
    if let sortedBy = sortedBy {
      sortDescriptors.append(NSSortDescriptor(key: sortedBy, ascending: ascending))
    }
    return try count(of: type, predicate: predicate, sortDescriptors: sortDescriptors)
  }
}
