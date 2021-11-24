//
//  AdvertisementDetailModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData

struct AdvertisementMetaInfo : Codable {
    var creationDate: Date
    var changedDate: Date
    var featured: Bool
    var availableLanguages: String
    var country: String?
}

struct AdvertisementDetailModel : Codable {
    var title: [String: String]
    var text: [String: String]
    var imageUrl: [String: String]
    var metaInfo: AdvertisementMetaInfo
}
