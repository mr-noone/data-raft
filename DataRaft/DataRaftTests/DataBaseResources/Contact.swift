//
//  Contact.swift
//  DataRaftTests
//
//  Created by Aleksey Zgurskiy on 18.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData
import DataRaft

@objc(Contact)
public class Contact: NSManagedObject {
  @NSManaged public var firstName: String?
  @NSManaged public var lastName: String?
  @NSManaged public var age: Int16
}
