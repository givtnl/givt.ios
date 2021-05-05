//
//  GetAllDonationsQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GetAllDonationsQueryHandler : RequestHandlerProtocol {
    let dataContext: CoreDataContext

    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        var result = [DonationDetailModel]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Donation")
        let donations = try dataContext.objectContext.fetch(fetchRequest)
        for donation in donations {
            result.append(DonationDetailModel(objectId: donation.objectID,
                                              mediumId: donation.value(forKey: "mediumId") as! String,
                                              collectId: donation.value(forKey: "collectId") as! String,
                                              amount: donation.value(forKey: "amount") as! Decimal,
                                              userId: UUID.init(uuidString: donation.value(forKey: "userId") as! String)!,
                                              timeStamp: donation.value(forKey: "timeStamp") as! Date))
        }
        try completion(result as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetAllDonationsQuery
    }
}
