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
    
    init(name: String, logo: UIImage?, mediumId: String, appScheme: String?, wasShownAlready: Bool = false) {
        self.name = name
        self.logo = logo
        self.mediumId = mediumId
        self.appScheme = appScheme
        self.wasShownAlready = wasShownAlready
    }
}
