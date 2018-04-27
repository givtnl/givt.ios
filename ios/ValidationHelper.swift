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
        let count = newString.count
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
        return string.count <= 70 && expression.firstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count)) != nil
    }
    
    func isPasswordValid(_ string: String) -> Bool {
        let expression = try! NSRegularExpression(pattern: ".*[0-9]+.*[A-Z]+.*|.*[A-Z]+.*[0-9]+.*", options: [])
        return (string.count > 6 && string.count <= 35) && expression.firstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count)) != nil
    }
    
    //long live stackoverflow
    func isIbanChecksumValid(_ iban: String) -> Bool {
        let ibanNoSpaces = iban.replacingOccurrences(of: " ", with: "")
        //shortest IBAN in SEPA is 15 char (Norway)
        if ibanNoSpaces.count < 15 {
            return false
        }
        
        let uppercase = ibanNoSpaces.uppercased()
        
        guard uppercase.range(of: "^[0-9A-Z]*$", options: .regularExpression) != nil else {
            return false
        }
        
        return (mod97(uppercase) == 1)
    }
    
    fileprivate func mod97(_ iban: String) -> Int {
        let symbols = iban
        let swapped = symbols.dropFirst(4) + symbols.prefix(4)
        
        let mod: Int = swapped.reduce(0) { (previousMod, char) in
            let value = Int(String(char), radix: 36)! // "0" => 0, "A" => 10, "Z" => 35
            let factor = value < 10 ? 10 : 100
            return (factor * previousMod + value) % 97
        }
        
        return mod
    }
    
    func isValidName(_ string: String) -> Bool {
        var allowedCharacters = CharacterSet.letters
        allowedCharacters.insert(" ")
        allowedCharacters.insert("-")
        allowedCharacters.insert("'")
        allowedCharacters.insert("’")
        //remove all allowed characters. When rest is not 0, means that we have unwanted characters.
        let rest = string.trimmingCharacters(in: allowedCharacters)
        let startsOrEndsWithIllegalCharacter = string.starts(with: " ") || string.starts(with: "-") || string.starts(with: "'") || string.starts(with: "’") || string.last == " " || string.last == "-" || string.last == "'" || string.last == "’"
        //if string start or ends with illegal character => return false
        return rest.count == 0 && !startsOrEndsWithIllegalCharacter
    }
    
    
}
