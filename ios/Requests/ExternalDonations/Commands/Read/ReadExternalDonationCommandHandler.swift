//
//  ReadExternalDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ReadExternalDonationCommandHandler: RequestHandlerProtocol {
    let dataContext: CoreDataContext

    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        var result = [ExternalDonationModel]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExternalDonation")
        let donations = try dataContext.objectContext.fetch(fetchRequest)
        for donation in donations {
            result.append(ExternalDonationModel(objectId: donation.objectID,
                                              guid: donation.value(forKey: "guid") as! String,
                                              name: donation.value(forKey: "name") as! String,
                                              amount: donation.value(forKey: "amount") as! Double,
                                              frequency: ExternalDonationFrequency(rawValue: donation.value(forKey: "frequency") as! Int)!
            ))
            
        }
        try completion(result as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is ReadExternalDonationCommand
    }
}
