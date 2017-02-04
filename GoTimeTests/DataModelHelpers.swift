//
//  DataModelTestsHelper.swift
//  GoTime
//
//  Created by John Keith on 2/1/17.
//  Copyright © 2017 John Keith. All rights reserved.
//

import XCTest
import CoreData

enum SaveManagedContextError: Error {
    case Fail
}

class DataModelHelpers {
    static let sharedInstance = DataModelHelpers()
    private init() {}
    
    class func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    class func saveManagedObjectContext(context: NSManagedObjectContext) throws -> Bool {
        do {
            try context.save()
            
            return true
        } catch {
            throw(SaveManagedContextError.Fail)
        }
    }
}

class FakeCoreDataService {
    static let shared = FakeCoreDataService()
    
    lazy var inMemoryManagedObjectContext: NSManagedObjectContext = {
        DataModelHelpers.setUpInMemoryManagedObjectContext()
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.inMemoryManagedObjectContext
    }()
    
    func save() throws {
        do {
            _ = try DataModelHelpers.saveManagedObjectContext(context: self.viewContext)
        } catch {
            throw(SaveManagedContextError.Fail)
        }
    }
}

