//
//  GetRandomAdvertisementQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 24/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GetRandomAdvertisementQueryHandler : RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! GetRandomAdvertisementQuery
        var langCode = request.localeLanguageCode.lowercased()
        if langCode == "en" {
            if ["us","gb"].contains(request.localeRegionCode.lowercased()) {
                langCode = "\(langCode)-\(request.localeRegionCode.lowercased())"
            } else {
                langCode = "en-eu"
            }
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Advertisement")
        let ads = (try dataContext.objectContext.fetch(fetchRequest)).filter {
            ($0.value(forKey: "availableLanguages") as! [String]).contains(langCode)
            && (request.country == nil
                || $0.value(forKey: "country") == nil
                || ($0.value(forKey: "country") as! [String]).contains(request.country!))
        }
        
        if ads.count == 0 {
            let result: LocalizedAdvertisementModel? = nil
            try completion(result as! R.TResponse)
            return
        }
        
        var ad = ads.first {
            ($0.value(forKey: "featured") as! Bool)
        }
        if ad == nil {
            ad = ads[Int.random(in: 0..<ads.count)]
        }
        guard let ad = ad else { throw GenericError.runtimeError("Ad should not be nil") }

        let title = (ad.value(forKey: "title") as! [String: String]).first{ $0.key.contains(langCode) }?.value
        let text = (ad.value(forKey: "text") as! [String:String]).first{ $0.key.contains(langCode) }?.value
        let imageUrl = (ad.value(forKey: "imageUrl") as! [String: String]).first{ $0.key.contains(langCode) }?.value
        try completion(LocalizedAdvertisementModel(title: title, text: text, imageUrl: imageUrl) as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetRandomAdvertisementQuery
    }
}
