//
//  GetUserDetailQuery.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal struct GetLocalUserConfiguration : RequestProtocol {
    typealias TResponse = LocalUserConfigurationModel
    
    public var country: String
}
