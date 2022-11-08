//
//  PutShareDataCommand.swift
//  ios
//
//  Created by Mike Pattyn on 07/11/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

class PutShareDataCommand : RequestProtocol {
    typealias TResponse = Bool

    let shareData: Bool
    
    init(shareData: Bool) {
        self.shareData = shareData
    }
}
