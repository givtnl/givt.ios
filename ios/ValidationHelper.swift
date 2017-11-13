//
//  ValidationHelper.swift
//  ios
///Users/lenniestockman/givt.ios/ios/Managers/LoginManager.swift
//  Created by Lennie Stockman on 27/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit


class ValidationHelper {
    static let shared = ValidationHelper()

    private init(){
        
    }
    
    func isBetweenCriteria(_ string: String, _ maxLength: Int) -> Bool {
        let newString = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let count = newString.characters.count
        return (count > 1 && count <= maxLength)
    }
    
    func isEmailAddressValid(_ string: String) -> Bool {
        let regex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let expression = try! NSRegularExpression(pattern: regex, options: [])
        return string.characters.count <= 70 && expression.firstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count)) != nil
    }
    
    func isPasswordValid(_ string: String) -> Bool {
        let expression = try! NSRegularExpression(pattern: ".*[0-9]+.*[A-Z]+.*|.*[A-Z]+.*[0-9]+.*", options: [])
        return (string.characters.count > 6 && string.characters.count <= 35) && expression.firstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count)) != nil
    }
    
    //long live stackoverflow
    func isIbanChecksumValid(_ iban: String) -> Bool {        
        let IBAN = iban.replacingOccurrences(of: " ", with: "").uppercased()
        var a = IBAN.utf8.map{ $0 }
        while a.count < 4 {
            a.append(0)
        }
        let b = a[4..<a.count] + a[0..<4]
        let c = b.reduce(0) { (r, u) -> Int in
            let i = Int(u)
            return i > 64 ? (100 * r + i - 55) % 97: (10 * r + i - 48) % 97
        }
        return c == 1
    }
    
    
}
