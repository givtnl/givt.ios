//
//  GetNotGivtDonationsQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 02/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GetNotGivtDonationsQueryHandler: RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
//        var result = [NotGivtDonationModel]()
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExternalDonation")
//        let externalDonations = try dataContext.objectContext.fetch(fetchRequest)
        
        let models: [NotGivtDonationModel] = [
            NotGivtDonationModel(guid: UUID().uuidString, name: "Rode kruis", amount: 50.0),
            NotGivtDonationModel(guid: UUID().uuidString, name: "Kom op tegen kanker", amount: 50.0)
        ]
        try? completion(models as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetNotGivtDonationsQuery
    }
}
