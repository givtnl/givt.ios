//
//  ValidationHelper.swift
//  ios
///Users/lenniestockman/givt.ios/ios/Managers/LoginManager.swift
//  Created by Lennie Stockman on 27/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import PhoneNumberKit
import UIKit


class ValidationHelper {
    private var phoneNumberKit = PhoneNumberKit()
    private var formattedPhoneNumber: String = ""


    static let shared = ValidationHelper()

    private init(){
        
    }
    
    func isBetweenCriteria(_ string: String, _ maxLength: Int) -> Bool {
        let newString = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let count = newString.count
        return (count > 1 && count <= maxLength)
    }
    
    func isEmailAddressValid(_ string: String) -> Bool {
        let firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstpart + "@" + serverpart + "[A-Za-z]{2,6}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return string.count <= 70 && emailPredicate.evaluate(with: string)
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
        allowedCharacters.insert(".")
        //remove all allowed characters. When rest is not 0, means that we have unwanted characters.
        let rest = string.trimmingCharacters(in: allowedCharacters)
        let startsOrEndsWithIllegalCharacter = string.starts(with: " ") || string.starts(with: "-") || string.starts(with: "'") || string.starts(with: "’") || string.last == " " || string.last == "-" || string.last == "'" || string.last == "’" || string.starts(with: ".")
        //if string start or ends with illegal character => return false
        return rest.count == 0 && !startsOrEndsWithIllegalCharacter
    }
    class PhoneResult{
        var IsValid: Bool
        var Number: String??
        init(isValid: Bool, number: String??){
            self.IsValid = isValid
            self.Number = number
        }
    }
    
    func isValidPhone(number: String) -> PhoneResult {
        
        var retVal: PhoneResult = PhoneResult(isValid: false, number: nil)

        for var item in AppConstants.countries {
            item = item as Country
            let prefix = item.phoneNumber.prefix.substring(1..<3)
            let first = item.phoneNumber.firstNumber
            let length = item.phoneNumber.length
            var totalMax = 1 + length
            if(number.count > 3){
                if(number.contains("+")){
                    totalMax += 3
                } else if(number.substring(0..<2)==("00")){
                    totalMax += 4
                } else {
                    totalMax += 1
                }
                
            }
            var regString: String = "\\+?"
                regString += prefix
                regString += first
                regString += "{1}[0-9]{"
                regString += String(length)
                regString += "}|0{2}?"
                regString += prefix
                regString += first
                regString += "{1}[0-9]{"
                regString += String(length)
                regString += "}|0{1}?"
                regString += first
                regString += "{1}[0-9]{"
                regString += String(length)
                regString += "}|"
                regString += first
                regString += "{1}[0-9]{"
                regString += String(length)
                regString += "}"

            let regEx = try! NSRegularExpression(pattern: regString)
            let results = regEx.matches(in: number, range: NSRange(number.startIndex..., in: number))
            if(results.count > 0 && number.count == totalMax){
                retVal = PhoneResult(isValid: true, number: nil)
                let lengteNummer = number.count
                let startIndex = lengteNummer-length
                retVal.Number = item.phoneNumber.prefix + item.phoneNumber.firstNumber + number.substring(startIndex..<lengteNummer)
                return retVal
            }
//            if(number.matches(regString) && number.count == (4+length)){
//                
//            }
        }

        
        return retVal
    }
    
}
