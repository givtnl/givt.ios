//
//  OpenFAQRoute.swift
//  ios
//
//  Created by Mike Pattyn on 06/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//
import Foundation

class OpenFAQRoute : NoResponseRequest {
    var fromReverseFlow: Bool
    init (fromReverseFlow: Bool) {
        self.fromReverseFlow = fromReverseFlow
    }
}
