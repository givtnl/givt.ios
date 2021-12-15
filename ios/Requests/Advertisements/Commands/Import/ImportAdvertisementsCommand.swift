//
//  ImportAdvertisementsCommand.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class ImportAdvertisementsCommand : NoResponseRequest {
    let lastChangedDate : Date
    
    init(lastChangedDate:Date) {
        self.lastChangedDate = lastChangedDate
    }
}
