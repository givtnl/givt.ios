//
//  OpenSafariInputModel.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
struct OpenSafariRouteInputModel : Codable {
    var message: String
    var Collect: String
    var AreYouSureToCancelGivts: String
    var ConfirmBtn: String
    var Cancel: String
    var SlimPayInformation: String
    var SlimPayInformationPart2: String
    var Close: String
    var ShareGivt: String
    var Thanks: String
    var YesSuccess: String
    var GUID: String
    var givtObj: [OpenSafariRouteTransactionModel]
    var apiUrl: String
    var organisation: String?
    var spUrl: String?
    var canShare: Bool
    var nativeAppScheme: String
    var urlPart: String
    var currency: String
    var advertisementText: String?
    var advertisementTitle: String?
    var advertisementImageUrl: String?
    var country: String
}
