//
//  DeleteDonationCommandHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DeleteDonationCommandHandler : RequestHandlerProtocol {
    let dataContext: CoreDataContext
    
    init () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataContext = appDelegate.coreDataContext
    }
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! DeleteDonationCommand
        let donation = try dataContext.objectContext.existingObject(with: request.objectId)
        dataContext.objectContext.delete(donation)
        BadgeService.shared.removeBadge(badge: .offlineGifts)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DeleteDonationCommand
    }
}
