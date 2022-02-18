//
//  GetCollectGroupsV2Query.swift
//  ios
//
//  Created by Mike Pattyn on 15/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class GetCollectGroupsV2Query: RequestProtocol {
    typealias TResponse = ResponseModel<BeaconList?>
}

struct CollectGroupAppListModel: Codable {
    var CGS: [CollectGroupListDetailModel] // CollectGroups
}

struct CollectGroupListDetailModel: Codable {
    var N: String // Name
    var NS: String // Namespace
    var C: Bool // Celebrations
    var T: Int // Type
    var L: [CollectGroupLocationDetailModel]? = nil // Locations
    var Q: [CollectGroupQrCodeDetailModel]? = nil // QrCodes
}

struct CollectGroupLocationDetailModel: Codable {
    var N: String? = nil // Name
    var LA: Double // Latitude
    var LO: Double // Longitude
    var R: Int // Radius
    var I: String // Instance
    var DB: String // DateBegin
    var DE: String // DateEnd
}

struct CollectGroupQrCodeDetailModel: Codable {
    var N: String? = nil // Name
    var I: String // Instance
    var A: Bool // Active
}
