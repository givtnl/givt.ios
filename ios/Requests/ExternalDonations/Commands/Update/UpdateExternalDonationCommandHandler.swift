//
//  UpdateExternalDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UpdateExternalDonationCommandHandler: RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! UpdateExternalDonationCommand
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExternalDonation")
        fetchRequest.predicate = NSPredicate(format: "guid = %@", argumentArray: [request.externalDonation.guid])
        
        let fetchResult = try dataContext.objectContext.fetch(fetchRequest)
        
        if fetchResult.count != 0 {
            fetchResult.first?.setValue(request.externalDonation.name, forKey: "name")
            fetchResult.first?.setValue(request.externalDonation.amount, forKey: "amount")
            fetchResult.first?.setValue(request.externalDonation.frequency.rawValue, forKey: "frequency")
        }
       
        try dataContext.saveToMainContext()
        
        try completion(fetchResult.first?.objectID as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is UpdateExternalDonationCommand
    }
}
