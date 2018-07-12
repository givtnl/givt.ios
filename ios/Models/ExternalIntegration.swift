//
//  ExternalIntegration.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation

class ExternalIntegration {
    var name: String
    var mediumId: String
    var appScheme: String
    
    init(name: String, mediumId: String, appScheme: String) {
        self.name = name
        self.mediumId = mediumId
        self.appScheme = appScheme
    }
}
