//
//  DiscoverOrAmountOpenSafariRoute.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SafariServices

class DiscoverOrAmountOpenSafariRoute : NoResponseRequest {
    var mandateUrl: String?
    var donations: [Transaction]
    var canShare: Bool
    var collectGroupName: String?
    var userId: UUID
    
    var delegate: SFSafariViewControllerDelegate

    internal init(donations: [Transaction], canShare: Bool, userId: UUID, delegate: SFSafariViewControllerDelegate, collectGroupName: String? = nil, mandateUrl: String? = nil) {
        self.mandateUrl = mandateUrl
        self.donations = donations
        self.canShare = canShare
        self.collectGroupName = collectGroupName
        self.userId = userId
        self.delegate = delegate
    }
}
