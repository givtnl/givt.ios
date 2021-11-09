//
//  CurrencyHelper.swift
//  ios
//
//  Created by Mike Pattyn on 09/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class CurrencyHelper {
    static let shared = CurrencyHelper()
    
    private var currentLocale: String? = nil
    
    func updateCurrentLocale(_ localeString: String) {
        if localeString.contains("_") {
            currentLocale = localeString.replacingOccurrences(of: "_", with: "-")
        } else {
            currentLocale = localeString
        }
        
    }
    
    func getLocalFormat(value: Float, decimals: Bool) -> String {
        return CurrencyFormatter().getLocalFormat(value: value, decimals: decimals, localeString: currentLocale!)
    }
    
    func getCurrencySymbol() -> String {
        return CurrencyFormatter().getCurrencySymbol(localeString: currentLocale!)
    }
}
