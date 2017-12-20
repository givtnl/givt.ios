//
//  AmountLimit.swift
//  ios
//
//  Created by Lennie Stockman on 19/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class AmountLimit: UITextField {
    
    /* override the menu options so it won't show */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

}
