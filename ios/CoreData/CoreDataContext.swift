//
//  CoreDataContext.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData

// https://stackoverflow.com/questions/52240107/correct-way-to-deal-with-persistentcontainer-instance-on-appdelegate/53659584

class CoreDataContext: NSObject {
    let moduleName = "CoreData"
    
    func saveToMainContext() throws {
        if objectContext.hasChanges {
            try objectContext.save()
        }
    }
    lazy var objectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var applicationDocumentsDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistenStoreURL = self.applicationDocumentsDirectory.appendingPathComponent("\(moduleName).sqlite")
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistenStoreURL,
                                               options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption : true])
        } catch {
            fatalError("Persistent Store error: \(error)")
        }
        return coordinator
    }()
}
