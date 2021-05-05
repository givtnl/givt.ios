//
//  CreateDonationCommandHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CreateDonationCommandHandler : RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateDonationCommand
        
        let donationEntity = NSEntityDescription.entity(forEntityName: "Donation", in: dataContext.objectContext)
        let donation = NSManagedObject(entity: donationEntity!, insertInto: dataContext.objectContext)
        donation.setValue(request.amount, forKey: "amount")
        donation.setValue(request.mediumId, forKey: "mediumId")
        donation.setValue(request.userId.uuidString, forKey: "userId")
        donation.setValue(request.timeStamp, forKey: "timeStamp")
        donation.setValue(request.collectId, forKey: "collectId")
        try dataContext.saveToMainContext()
        
        BadgeService.shared.addBadge(badge: .offlineGifts)
        
        try completion(donation.objectID as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateDonationCommand
    }
}
