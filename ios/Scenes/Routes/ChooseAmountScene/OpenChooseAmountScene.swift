//
//  OpenChooseAmountScene.swift
//  ios
//
//  Created by Maarten Vergouwe on 17/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class OpenChooseAmountScene : NoResponseRequest {
    var name: String
    var mediumId: String
    
    init (name: String, mediumId: String) {
        self.name = name
        self.mediumId = mediumId
    }
}
