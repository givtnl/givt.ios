//
//  GetLastDateQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GetAdvertisementsLastDateQueryHandler : RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        var date = Date(timeIntervalSince1970: 0.0)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Advertisement")
        let ads = try dataContext.objectContext.fetch(fetchRequest)
        for ad in ads {
            if let adDate = ad.value(forKey: "changedDate") as? Date, adDate > date {
                date = adDate
            }
        }
        // need to add a second, since in the server database there may be milliseconds
        date.addTimeInterval(1)
        try? completion(date as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetAdvertisementsLastDateQuery
    }
}
