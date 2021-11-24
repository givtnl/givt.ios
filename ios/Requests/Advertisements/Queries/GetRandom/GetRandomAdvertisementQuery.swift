//
//  GetRandomAdvertisementQuery.swift
//  ios
//
//  Created by Maarten Vergouwe on 24/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetRandomAdvertisementQuery : RequestProtocol {
    typealias TResponse = LocalizedAdvertisementModel
    
    var country: String? = nil
}
