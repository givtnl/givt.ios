//
//  GetPublicMetaQuery.cs.swift
//  ios
//
//  Created by Maarten Vergouwe on 20/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

struct GetUserHasDonationsQuery : RequestProtocol {
    typealias TResponse = Bool
    
    var userId: String
    var forceSyncServer: Bool = false
}
