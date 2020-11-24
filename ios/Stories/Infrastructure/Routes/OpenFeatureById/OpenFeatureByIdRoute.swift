//
//  OpenFeatureByIdRoute.swift
//  ios
//
//  Created by Mike Pattyn on 24/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class OpenFeatureByIdRoute : NoResponseRequest {
    var featureId: Int
    init(featureId: Int) {
        self.featureId = featureId
    }
}
