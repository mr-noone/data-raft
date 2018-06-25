//
//  DataRaftError.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 16.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation

public enum DataRaftError: Error {
  case ObjectModelNotFound
  
  var localizedDescription: String {
    switch self {
    case .ObjectModelNotFound: return "The data model file not found."
    }
  }
}
