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
        var totalMax: Int

        let retVal: PhoneResult = PhoneResult(isValid: false, number: nil)
        if(number.count > 4){
            var item: PhoneNumber
            if(number.starts(with: "0032") || number.starts(with: "+32") || number.starts(with: "04") || number.starts(with: "4")){
                item = AppConstants.countries.first(where: { $0.phoneNumber.prefix == "+32"})!.phoneNumber
                if(number.starts(with: "0032") || number.starts(with: "+32")){
                    if(number.starts(with: "0032")){ totalMax = 13 } else { totalMax = 12 }
                    if let range2 = number.range(of: "32") {
                        let endPos = number.distance(from: number.startIndex, to: range2.upperBound)
                        if(number.substring(endPos..<endPos+1) == "4" && number.count == totalMax){
                            return returnValidPhone(number: number, phoneNumber: item)
                        }
                    }
                } else if(number.starts(with: "04")) { totalMax = 10
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                } else if(number.starts(with: "4")) { totalMax = 9
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                }
            } else if(number.starts(with: "0031") || number.starts(with: "+31") || number.starts(with: "06") || number.starts(with: "6")){
                item = AppConstants.countries.first(where: { $0.phoneNumber.prefix == "+31"})!.phoneNumber
                if(number.starts(with: "0031") || number.starts(with: "+31")){
                    if(number.starts(with: "0031")){ totalMax = 13 } else { totalMax = 12 }
                    if let range2 = number.range(of: "31") {
                        let endPos = number.distance(from: number.startIndex, to: range2.upperBound)
                        if(number.substring(endPos..<endPos+1) == "6" && number.count == totalMax){
                            return returnValidPhone(number: number, phoneNumber: item)
                        }
                    }
                } else if(number.starts(with: "06")) { totalMax = 10
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                } else if(number.starts(with: "6")) { totalMax = 9
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                }
            } else if(number.starts(with: "0049") || number.starts(with: "+49") || number.starts(with: "01") || number.starts(with: "1")){
                item = AppConstants.countries.first(where: { $0.phoneNumber.prefix == "+49"})!.phoneNumber
                if(number.starts(with: "0049") || number.starts(with: "+49")){
                    if(number.starts(with: "0049")){ totalMax = 14 } else { totalMax = 13 }
                    if let range2 = number.range(of: "49") {
                        let endPos = number.distance(from: number.startIndex, to: range2.upperBound)
                        if(number.substring(endPos..<endPos+1) == "1" && number.count == totalMax){
                            return returnValidPhone(number: number, phoneNumber: item)
                        }
                    }
                } else if(number.starts(with: "01")) { totalMax = 11
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                } else if(number.starts(with: "1")) { totalMax = 10
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                }
            } else if(number.starts(with: "0044") || number.starts(with: "+44") || number.starts(with: "07") || number.starts(with: "7")){
                item = AppConstants.countries.first(where: { $0.phoneNumber.prefix == "+44"})!.phoneNumber
                if(number.starts(with: "0044") || number.starts(with: "+44")){
                    if(number.starts(with: "0044")){ totalMax = 14 } else { totalMax = 13 }
                    if let range2 = number.range(of: "44") {
                        let endPos = number.distance(from: number.startIndex, to: range2.upperBound)
                        if(number.substring(endPos..<endPos+1) == "7" && number.count == totalMax){
                            return returnValidPhone(number: number, phoneNumber: item)
                        }
                    }
                } else if(number.starts(with: "07")) { totalMax = 11
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                } else if(number.starts(with: "7")) { totalMax = 10
                    if(number.count == totalMax){
                        return returnValidPhone(number: number, phoneNumber: item)
                    }
                }
            }
        }
        return retVal
    }
    func returnValidPhone(number: String, phoneNumber: PhoneNumber) -> PhoneResult {
        let retVal = PhoneResult(isValid: true, number: nil)
        let lengteNummer = number.count
        let startIndex = lengteNummer-phoneNumber.length
        retVal.Number = phoneNumber.prefix + phoneNumber.firstNumber + number.substring(startIndex..<lengteNummer)
        return retVal
    }
    
}
