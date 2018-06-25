//
//  URL+StoreHelpers.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 17.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation

extension URL {
  init?(storeURLWithPath path: String?, modelName: String, in bundle: Bundle) {
    if let path = path, path.isEmpty == false {
      self.init(fileURLWithPath: path)
    } else {
      self.init(fileURLWithURL: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first)
      self.appendPathComponent(bundle.bundleIdentifier ?? "DB", isDirectory: true)
    }
    
    self.appendPathComponent(modelName)
    self.appendPathExtension("sqlite")
  }
  
  init?(fileURLWithURL url: URL?) {
    if let path = url?.relativePath {
      self.init(fileURLWithPath: path)
    } else {
      return nil
    }
  }
}
