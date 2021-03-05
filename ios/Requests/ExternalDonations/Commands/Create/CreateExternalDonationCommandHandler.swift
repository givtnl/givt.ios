//
//  CreateExternalDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CreateExternalDonationCommandHandler: RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateExternalDonationCommand
        
        let donationEntity = NSEntityDescription.entity(forEntityName: "ExternalDonation", in: dataContext.objectContext)
        let donation = NSManagedObject(entity: donationEntity!, insertInto: dataContext.objectContext)
        donation.setValue(request.guid, forKey: "guid")
        donation.setValue(request.name, forKey: "name")
        donation.setValue(request.amount, forKey: "amount")
        donation.setValue(request.frequency.rawValue, forKey: "frequency")
        try dataContext.saveToMainContext()
        
        try completion(donation.objectID as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateExternalDonationCommand
    }
}
