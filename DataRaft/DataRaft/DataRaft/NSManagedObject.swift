//
//  ManagedObject.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 18.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
  public static var entityName: String {
    return String(describing: self)
  }
}
