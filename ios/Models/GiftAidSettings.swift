//
//  GiftAidSettings.swift
//  ios
//
//  Created by Jonas Brabant on 28/02/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
class GiftAidSettings: BaseGiftAidSettings {
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
}

class BaseGiftAidSettings: NSObject, NSCoding {
    var shouldAskForGiftAidPermission: Bool = false
    override init() {}
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(shouldAskForGiftAidPermission, forKey: "shouldAskForGiftAidPermission")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.shouldAskForGiftAidPermission = aDecoder.decodeBool(forKey: "shouldAskForGiftAidPermission")
    }
}
