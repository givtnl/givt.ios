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
        guard let currentQueue = OperationQueue.current?.underlyingQueue else { try? completion(() as! R.TResponse); return }
        APIClient.cloud.head(url: "/api/advertisements") { response in
            currentQueue.async {
                if response?.statusCode == 200 {
                    APIClient.cloud.get(url: "/api/advertisements", data: [:]) { response in
                        currentQueue.async {
                            if response?.statusCode == 200 {
                                self.saveData(data: (response?.data)!)
                            }
                            try? completion(() as! R.TResponse)
                        }
                    }
                } else {
                    try? completion(() as! R.TResponse)
                }
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is ImportAdvertisementsCommand
    }
    
    private func saveData(data:Data) {
        if let advertisements = try? JSONDecoder().decode([AdvertisementDetailModel].self, from: data) {
            for ad in advertisements {
                let advertisementEntity = NSEntityDescription.entity(forEntityName: "Advertisement", in: dataContext.objectContext)
                let advertisement = NSManagedObject(entity: advertisementEntity!, insertInto: dataContext.objectContext)
                advertisement.setValue(ad.imageUrl, forKey: "imageUrl")
                try! dataContext.saveToMainContext()
            }
        } else {
            print("Could not parse advertisements from response")
        }
    }
}
