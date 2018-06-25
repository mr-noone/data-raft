//
//  Context+Sate.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 18.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
  /// Attempts to commit unsaved changes to registered objects to the persistent store.
  public func saveToStore() throws {
    var error: Error? = nil
    
    performAndWait {
      if hasChanges {
        do {
          try save()
          if let parent = parent {
            try parent.saveToStore()
          }
        } catch let anError {
          error = anError
          return
        }
      }
    }
    
    if let error = error {
      throw error
    }
  }
}
