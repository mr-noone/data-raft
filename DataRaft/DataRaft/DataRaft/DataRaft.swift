//
//  DataRaft.swift
//  DataRaft
//
//  Created by Aleksey Zgurskiy on 15.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import Foundation
import CoreData

public protocol DataRaftDelegate: AnyObject {
  func dataRaft(_ dataRaft: DataRaft, didCreate context: NSManagedObjectContext)
  func dataRaft(_ dataRaft: DataRaft, didCreate model: NSManagedObjectModel)
}

public extension DataRaftDelegate {
  func dataRaft(_ dataRaft: DataRaft, didCreate context: NSManagedObjectContext) {}
  func dataRaft(_ dataRaft: DataRaft, didCreate model: NSManagedObjectModel) {}
}

public final class DataRaft {
  private var storeCoordinator: NSPersistentStoreCoordinator!
  private var mainContext: NSManagedObjectContext!
  private var isConfigured = false
  
  public weak var delegate: DataRaftDelegate?
  
  public init() {}
  
  /// This function configure CoreData stack.
  ///
  /// - Parameters:
  ///   - type: An enum (such as .inMemory) that specifies the store type. By default .inMemory.
  ///   - modelName: The name of data model file.
  ///   - bundle: The bundle where is located your data model file. By default the main bundle.
  ///   - storePath: The file location of the persistent store. This value may be nil.
  ///   - options: A dictionaty containing key-value pairs thet specife whether thr store should be read-only, and migration options. This value may be nil.
  /// - Throws: Throws error when data model not found or could not create the path to persistent store or couldn't add the persistent store.
  public func configure(type: StoreType = .inMemory, modelName: String, bundle: Bundle = .main, storePath: String? = nil, options: [String : Any]? = nil) throws {
    guard
      let modelUrl = bundle.url(forResource: modelName, withExtension: "momd"),
      let model = NSManagedObjectModel(contentsOf: modelUrl), modelName.count > 0
    else {
      throw DataRaftError.ObjectModelNotFound
    }
    
    delegate?.dataRaft(self, didCreate: model)
    
    var storeUrl: URL?
    if type == .sqLite {
      storeUrl = URL(storeURLWithPath: storePath, modelName: modelName, in: bundle)
      try FileManager.default.createDirectory(at: storeUrl!.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    }
    
    var options = options ?? [String : Any]()
    if options.isEmpty {
      options[NSMigratePersistentStoresAutomaticallyOption] = true
      options[NSInferMappingModelAutomaticallyOption] = true
    }
    
    storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try storeCoordinator.addPersistentStore(ofType: type.rawValue, configurationName: nil, at: storeUrl, options: options)
    
    isConfigured = true
  }
  
  /// This function configure CoreData stack asynchronously.
  ///
  /// - Parameters:
  ///   - type: An enum (such as .inMemory) that specifies the store type. By default .inMemory.
  ///   - modelName: The name of data model file.
  ///   - bundle: The bundle where is located your data model file. By default the main bundle.
  ///   - storePath: The file location of the persistent store. This value may be nil.
  ///   - options: A dictionaty containing key-value pairs thet specife whether thr store should be read-only, and migration options. This value may be nil.
  ///   - completion: Called when configuration is completed. When configuration faild, closure provides you error. This value may be nil.
  public func configureAsync(type: StoreType = .inMemory, modelName: String, bundle: Bundle = .main, storePath: String? = nil, options: [String : Any]? = nil, completion: ((Error?) -> ())? = nil) {
    DispatchQueue.global(qos: .userInteractive).async {
      do {
        try self.configure(type: type, modelName: modelName, bundle: bundle, storePath: storePath, options: options)
        DispatchQueue.main.async { completion?(nil) }
      } catch {
        DispatchQueue.main.async { completion?(error) }
      }
    }
  }
  
  /// Return the main context for current stack.
  ///
  /// - Returns: The instance of NSManagedObjectContext.
  public func main() -> NSManagedObjectContext {
    guard isConfigured else {
      fatalError("DataRaft is not configured.")
    }
    
    if mainContext == nil {
      mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
      mainContext.persistentStoreCoordinator = storeCoordinator
      delegate?.dataRaft(self, didCreate: mainContext)
    }
    
    return mainContext!
  }
  
  /// Creates and return the new private context for current stack.
  ///
  /// - Returns: The instance of NSManagedObjectContext.
  public func `private`() -> NSManagedObjectContext {
    guard isConfigured else {
      fatalError("DataRaft is not configured.")
    }
    
    let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateContext.parent = main()
    delegate?.dataRaft(self, didCreate: privateContext)
    return privateContext
  }
  
  /// Deletes all objects from the persistent store.
  ///
  /// - Throws: Throws error if there is a problem executing the fetch.
  public func clear() throws {
    var error: Error? = nil
    let context = `private`()
    
    context.performAndWait {
      do {
        try storeCoordinator.managedObjectModel.entities.compactMap { $0.name }.forEach {
          let request = NSFetchRequest<NSManagedObject>(entityName: $0)
          request.includesPropertyValues = false
          try context.fetch(request).forEach {
            context.delete($0)
          }
        }
        try context.saveToStore()
      } catch let anError {
        error = anError
      }
    }
    
    if let error = error {
      throw error
    }
  }
}
