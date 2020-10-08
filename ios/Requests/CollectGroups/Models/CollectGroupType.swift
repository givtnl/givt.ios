//
//  CollectGroupType.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

enum CollectGroupType : Int, Codable {
    case church = 0
    case campaign = 1
    case artist = 2
    case charity = 3
    case unknown = 4
    case demo = 5
    case debug = 6
    case none = 7
}
