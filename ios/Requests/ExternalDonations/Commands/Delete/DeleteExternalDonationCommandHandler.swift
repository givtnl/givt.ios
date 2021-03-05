//
//  DeleteExternalDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DeleteExternalDonationCommandHandler: RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! DeleteExternalDonationCommand
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExternalDonation")
        fetchRequest.predicate = NSPredicate(format: "guid = %@", argumentArray: [request.guid])
        
        let fetchResult = try dataContext.objectContext.fetch(fetchRequest)
        
        if fetchResult.count != 0 {
            dataContext.objectContext.delete(fetchResult.first!)
        }
       
        try dataContext.saveToMainContext()
        
        try completion(fetchResult.first?.objectID as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DeleteExternalDonationCommand
    }
}
