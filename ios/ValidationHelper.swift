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
    func isValidUKPostalCode(string: String) -> Bool {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if(!trimmedString.contains(" ")) {
            return false
        }
        
        let splitString = trimmedString.components(separatedBy: " ")
        
        if(splitString.count != 2) {
            return false
        }
        
        if(splitString[0].count < 2 || splitString[1].count != 3) {
            return false
        }
        
        return true
    }
    func isEmailAddressValid(_ string: String) -> Bool {
        let firstpart = "([A-Z0-9a-z._%+-]{0,30})?"
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
        
        // validate first two characters are letters
        if ibanNoSpaces.count > 2 {
            let firstTwoCharacters = ibanNoSpaces.prefix(2)
            guard firstTwoCharacters.range(of: "^[A-Z]*$", options: .regularExpression) != nil else {
                return false
            }
        }
        
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

    func isValidCityOrAddress(string: String, illegalStartingOrEndingCharacters: Array<Character>) -> Bool {
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: " -'.,‘/")
        //remove all allowed characters. When rest is not 0, means that we have unwanted characters.
        let rest = string.trimmingCharacters(in: allowedCharacters)
        let trimmedString = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let startsOrEndsWithIllegalCharacter = illegalStartingOrEndingCharacters.reduce(false) { (result, next) in
            return result || trimmedString.starts(with: String(next)) || trimmedString.last == next
        }
        //if string start or ends with illegal character => return false
        return rest.count == 0 && !startsOrEndsWithIllegalCharacter

    }
    
    func isValidCity(string: String) -> Bool {
        let illegalStartingOrEndingCharacters = Array(" -.,")
        return isValidCityOrAddress(string: string, illegalStartingOrEndingCharacters: illegalStartingOrEndingCharacters)
    }
    
    func isValidAddress(string: String) -> Bool {
        let illegalStartingOrEndingCharacters = Array(" -'‘.,")
        return isValidCityOrAddress(string: string, illegalStartingOrEndingCharacters: illegalStartingOrEndingCharacters)
    }
    
    public class PhoneResult{
        var IsValid: Bool
        var Number: String?
        init(isValid: Bool, number: String?){
            self.IsValid = isValid
            self.Number = number
        }
    }
    func isValidPhoneWithPrefix(number: String, country: Country) -> PhoneResult {
        var temp = number
        if temp.starts(with: country.phoneNumber.prefix) {
            temp = temp.replacingOccurrences(of: country.phoneNumber.prefix, with: "")
        } else if temp.starts(with: country.phoneNumber.prefixWithZeros) {
            temp = temp.replacingOccurrences(of: country.phoneNumber.prefixWithZeros, with: "")
        } else if temp.starts(with: "0") {
            temp.remove(at: temp.startIndex)
        }
        
        for p in country.phoneNumber.firstNumbers {
            if temp.starts(with: p) {
                // add one more to length if country is germany and first numbers after prefix is "16" because this phonenumber can be 10 or 11 characters long after prefix
                let length = p.count + country.phoneNumber.length
                if (country.shortName == "DE" && (length == temp.count || length == temp.count+1)) || length == temp.count {
                    do {
                        let phoneNumber = try phoneNumberKit.parse(country.phoneNumber.prefix + temp, withRegion: country.shortName, ignoreType: true)
                        formattedPhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
                        return PhoneResult(isValid: true, number: formattedPhoneNumber)
                    }
                    catch {
                        formattedPhoneNumber = ""
                        return PhoneResult(isValid: false, number: nil)
                    }
                }
            }
        }
        return PhoneResult(isValid: false, number: nil)
    }
    func isValidPhone(number: String) -> PhoneResult {
        let countrysToValidate = AppConstants.countries.filter{
            $0.shortName == "NL" ||
            $0.shortName == "BE" ||
            $0.shortName == "DE" ||
            $0.shortName == "GB" ||
            $0.shortName == "GG" ||
            $0.shortName == "JE"
        }
        for country in  countrysToValidate {
            var temp = number
            if temp.starts(with: country.phoneNumber.prefix) {
                temp = temp.replacingOccurrences(of: country.phoneNumber.prefix, with: "")
            } else if temp.starts(with: country.phoneNumber.prefixWithZeros) {
                temp = temp.replacingOccurrences(of: country.phoneNumber.prefixWithZeros, with: "")
            } else if temp.starts(with: "0") {
                temp.remove(at: temp.startIndex)
            }
            
            for p in country.phoneNumber.firstNumbers {
                if temp.starts(with: p) {
                    // add one more to length if country is germany and first numbers after prefix is "16" because this phonenumber can be 10 or 11 characters long after prefix
                    let length = p.count + country.phoneNumber.length
                    if (country.shortName == "DE" && (length == temp.count || length == temp.count+1)) || length == temp.count {
                        do {
                            let phoneNumber = try phoneNumberKit.parse(country.phoneNumber.prefix + temp, withRegion: country.shortName, ignoreType: true)
                            formattedPhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
                            return PhoneResult(isValid: true, number: formattedPhoneNumber)
                        }
                        catch {
                            formattedPhoneNumber = ""
                            return PhoneResult(isValid: false, number: nil)
                        }
                    }
                }
            }
        }
        return PhoneResult(isValid: false, number: nil)
    }
    func isValidSortcode(s: String) -> Bool {
        return s.count == 6
    }
    func isValidAccountNumber(s: String) -> Bool {
        return s.count == 8
    }
}
