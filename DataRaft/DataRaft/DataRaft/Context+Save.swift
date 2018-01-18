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
    public func saveToStore() throws {
        var error: Error? = nil
        
        performAndWait {
            if hasChanges {
                do {
                    try save()
                    if let parent = parent {
                        try parent.saveToStore()
                    }
                } catch let err {
                    error = err
                    return
                }
            }
        }
        
        if let error = error {
            throw error
        }
    }
}
