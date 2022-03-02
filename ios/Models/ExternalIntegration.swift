//
//  ExternalIntegration.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class ExternalAppIntegration {
    var name: String
    var logo: UIImage?
    var mediumId: String
    var appScheme: String?
    var wasShownAlready: Bool
        
    init(mediumId: String, name: String = "normal", logo: UIImage? = UIImage(named: "givt_mobile"),  appScheme: String? = nil, wasShownAlready: Bool = false) {
        self.name = name
        self.logo = logo
        self.mediumId = mediumId
        self.appScheme = appScheme
        self.wasShownAlready = wasShownAlready
    }
    
    
    var entryKind: ExternalSuggestionKind {
        get {
            switch name {
                case "normal":
                    return .Normal
                case "QR":
                    return .QRCode
                default:
                    return .OtherApp
            }
        }
    }
    
    enum ExternalSuggestionKind {
        case Normal, QRCode, OtherApp
    }
    
    var namespace: String {
        get {
            if mediumId.contains(".") {
                return mediumId.split(separator: ".")[0].toString()
            } else {
                return mediumId
            }
        }
    }
}

