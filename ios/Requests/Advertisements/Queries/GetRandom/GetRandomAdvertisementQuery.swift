//
//  GetRandomAdvertisementQuery.swift
//  ios
//
//  Created by Maarten Vergouwe on 24/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetRandomAdvertisementQuery : RequestProtocol {
    typealias TResponse = LocalizedAdvertisementModel?
    
    var localeLanguageCode: String
    var localeRegionCode: String
    var country: String? = nil
    
    init(localeLanguageCode: String, localeRegionCode: String, country: String? = nil) {
        self.localeRegionCode = localeRegionCode
        self.localeLanguageCode = localeLanguageCode
        self.country = country
    }
}
