//
//  ImportAdvertisementsCommandHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ImportAdvertisementsCommandHandler : RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! ImportAdvertisementsCommand
        guard Thread.isMainThread else { throw ThreadError.notOnMainThread }

        let formatter = ISO8601DateFormatter()
        APIClient.cloud.head(url: "/advertisements", headers: ["If-Modified-Since": formatter.string(from: request.lastChangedDate)]) { response in
            if response?.statusCode == 200 {
                APIClient.cloud.get(url: "/advertisements", data: [:]) { response in
                    DispatchQueue.main.async {
                        if response?.statusCode == 200 {
                            self.saveData(data: (response?.data)!)
                            try? completion(() as! R.TResponse)
                        } else {
                            try? completion(() as! R.TResponse)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async { try? completion(() as! R.TResponse) }
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is ImportAdvertisementsCommand
    }
    
    private func saveData(data:Data) {
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            let advertisements = try jsonDecoder.decode([AdvertisementDetailModel].self, from: data)
            
            let fetchRequest = NSFetchRequest(entityName: "Advertisement") as! NSFetchRequest<NSFetchRequestResult>
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try dataContext.objectContext.persistentStoreCoordinator?.execute(deleteRequest, with: dataContext.objectContext)
            
            for ad in advertisements {
                let advertisementEntity = NSEntityDescription.entity(forEntityName: "Advertisement", in: dataContext.objectContext)
                let advertisement = NSManagedObject(entity: advertisementEntity!, insertInto: dataContext.objectContext)
                advertisement.setValue(NSDictionary(dictionary: ad.title), forKey: "title")
                advertisement.setValue(NSDictionary(dictionary: ad.text), forKey: "text")
                advertisement.setValue(NSDictionary(dictionary: ad.imageUrl), forKey: "imageUrl")
                advertisement.setValue(ad.metaInfo.changedDate, forKey: "changedDate")
                advertisement.setValue(ad.metaInfo.featured, forKey: "featured")
                advertisement.setValue(ad.metaInfo.creationDate, forKey: "creationDate")
                advertisement.setValue(ad.metaInfo.availableLanguages.components(separatedBy: ","), forKey: "availableLanguages")
                advertisement.setValue(ad.metaInfo.country?.components(separatedBy: ","), forKey: "country")
                try dataContext.saveToMainContext()
            }
        } catch {
            LogService.shared.error(message: "Could not load advertisements: \(error)")
        }
    }
}
