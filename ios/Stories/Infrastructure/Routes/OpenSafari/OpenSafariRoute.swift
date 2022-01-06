//
//  DiscoverOrAmountOpenSafariRoute.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SafariServices

class OpenSafariRoute : RequestProtocol {
    typealias TResponse = SFSafariViewController //to retain the viewcontroller
    
    var mandateUrl: String?
    var donations: [Transaction]
    var canShare: Bool
    var collectGroupName: String?
    var userId: UUID
    
    var delegate: SFSafariViewControllerDelegate
    
    var advertisement: LocalizedAdvertisementModel?

    var country: String
    
    internal init(donations: [Transaction], canShare: Bool, userId: UUID, delegate: SFSafariViewControllerDelegate, collectGroupName: String? = nil, mandateUrl: String? = nil, country: String) {
        self.mandateUrl = mandateUrl
        self.donations = donations
        self.canShare = canShare
        self.collectGroupName = collectGroupName
        self.userId = userId
        self.delegate = delegate
        self.country = country
    }
}
