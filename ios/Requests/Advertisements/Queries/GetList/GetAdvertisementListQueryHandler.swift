//
//  GetAdvertisementListQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
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
            result.append(AdvertisementDetailModel(
                title: ad.value(forKey: "title") as! Dictionary<String, String>,
                text: ad.value(forKey: "text") as! Dictionary<String, String>,
                imageUrl: ad.value(forKey: "imageUrl") as! Dictionary<String, String>,
                metaInfo: AdvertisementMetaInfo(
                    creationDate: ad.value(forKey: "creationDate") as! Date,
                    changedDate: ad.value(forKey: "changedDate") as! Date,
                    featured: ad.value(forKey: "featured") as! Bool,
                    availableLanguages: (ad.value(forKey: "availableLanguages") as! [String]).joined(separator: ","),
                    country: (ad.value(forKey: "country") as! [String]?)?.joined(separator: ","))))
        }
        try completion(result as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetAdvertisementListQuery
    }
}
