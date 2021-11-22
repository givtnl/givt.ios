//
//  GetAdvertisementListQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import Mixpanel
import CoreData

class GetAdvertismentListQueryHandler : RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        var result = [AdvertisementDetailModel]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Advertisement")
        let ads = try dataContext.objectContext.fetch(fetchRequest)
        for ad in ads {
            result.append(AdvertisementDetailModel(imageUrl: ad.value(forKey: "imageUrl") as! String))
        }
        try completion(result as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetAdvertisementListQuery
    }
}
