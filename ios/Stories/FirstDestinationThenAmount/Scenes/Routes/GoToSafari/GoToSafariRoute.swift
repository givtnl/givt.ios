//
//  GoToSafariRoute.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GoToSafariRoute : NoResponseRequest {
    var mandateUrl: String?
    var donations: [Transaction]
    var canShare: Bool
    var collectGroupName: String?
    var userId: UUID

    internal init(donations: [Transaction], canShare: Bool, userId: UUID, collectGroupName: String? = nil, mandateUrl: String? = nil) {
        self.mandateUrl = mandateUrl
        self.donations = donations
        self.canShare = canShare
        self.collectGroupName = collectGroupName
        self.userId = userId
    }
}
