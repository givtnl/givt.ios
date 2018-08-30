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
    
    func isValidNumeric(string: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
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
            let possiblePrefixes = [
                ["0032","+32","04","4"],
                ["0031","+31","06","6"],
                ["0049","+49","01","1"],
                ["0044","+44","07","7"]
            ]
            let totalMaxes = [ 8, 8, 9, 9]
            var item: PhoneNumber

            for (row, possiblePrefix) in possiblePrefixes.enumerated() {
                for (_, element) in possiblePrefix.enumerated() {
                    if(number.starts(with: element)){
                        item = AppConstants.countries.first(where: { $0.phoneNumber.prefix == String(possiblePrefixes[row][1])})!.phoneNumber
                        if(number.starts(with: String(possiblePrefixes[row][0])) || number.starts(with: String(possiblePrefixes[row][1]))){
                            if(number.starts(with: String(possiblePrefixes[row][0]))){ totalMax = totalMaxes[row] + 5 } else { totalMax = totalMaxes[row] + 4 }
                            if let range2 = number.range(of: String(possiblePrefixes[row][1]).substring(1..<3)) {
                                let endPos = number.distance(from: number.startIndex, to: range2.upperBound)
                                if(number.substring(endPos..<endPos+1) == String(possiblePrefixes[row][3]) && number.count == totalMax){
                                    return returnValidPhone(number: number, phoneNumber: item)
                                }
                            }
                        } else if(number.starts(with: String(possiblePrefixes[row][2]))) { totalMax = totalMaxes[row] + 2
                            if(number.count == totalMax){
                                return returnValidPhone(number: number, phoneNumber: item)
                            }
                        } else if(number.starts(with: String(possiblePrefixes[row][3]))) { totalMax = totalMaxes[row] + 1
                            if(number.count == totalMax){
                                return returnValidPhone(number: number, phoneNumber: item)
                            }
                        }
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
