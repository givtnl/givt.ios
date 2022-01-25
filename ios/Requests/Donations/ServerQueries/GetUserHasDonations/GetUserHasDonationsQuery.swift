//
//  GetPublicMetaQuery.cs.swift
//  ios
//
//  Created by Maarten Vergouwe on 20/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

struct GetUserHasDonations : RequestProtocol {
    typealias TResponse = Bool
    
    var userId: String
}
