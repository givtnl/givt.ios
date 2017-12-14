//
//  LoginManager.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit
import SwiftClient

class LoginManager {
    
    private var client: APIClient = APIClient.shared
    private var authClient: AuthClient = AuthClient.shared
    private var log: LogService = LogService.shared
    
    enum UserClaims: Int {
        case startedApp
        case giveOnce
        case give
    }
    
    static let shared = LoginManager()
    private var _registrationUser = UserExt()
    
    
    private init() {
        userClaim = UserDefaults.standard.isLoggedIn ? .give : .startedApp
    }
    
    public var userClaim: UserClaims {
        get {
            return UserClaims.init(rawValue: UserDefaults.standard.userClaims)!
        }
        set(value){
            UserDefaults.standard.userClaims = value.rawValue
        }
    }
    
    public var isFullyRegistered: Bool {
        get {
            return UserDefaults.standard.mandateSigned && (UserDefaults.standard.amountLimit != .max || UserDefaults.standard.amountLimit != -1)
        }
    }
    
    public var isBearerStillValid: Bool {
        if let bearerToken = UserDefaults.standard.bearerToken, Date() < UserDefaults.standard.bearerExpiration && !bearerToken.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    private var _baseUrl = "https://givtapidebug.azurewebsites.net"
    
    public func saveAmountLimit(_ amountLimit: Int, completionHandler: @escaping (Bool) -> Void) {
        //post request to amount limit api
        let url = "/api/users"
        let data = ["GUID" : (UserDefaults.standard.userExt?.guid)!, "AmountLimit" : String(amountLimit)]
        do {
            try client.put(url: url, data: data) { (res) in
                if let res = res, res.basicStatus == .ok {
                    UserDefaults.standard.amountLimit = amountLimit
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        } catch {
            log.error(message: "Something went wrong saving amount limit")
        }
        

    }
    
    public func loginUser(email: String, password: String, completionHandler: @escaping (Bool, NSError?, String?) -> Void ) {
        var params: [String : String] = [:]
        if UserDefaults.standard.hasPinSet {
            params = ["grant_type":"pincode","userName":email,"pincode":password]
        } else {
            params = ["grant_type":"password","userName":email,"password":password]
            
        }
        do {
            try authClient.post(url: "/oauth2/token", data: params) { (res) in
                if let temp = res, let data = temp.data {
                    if res?.basicStatus == .ok {
                        self.log.info(message: "Logging user in")
                        do
                        {
                            let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                            print(parsedData)
                            if let accessToken = parsedData["access_token"] as? String, let expiration = parsedData[".expires"] as? String {
                                UserDefaults.standard.bearerToken = accessToken
                                let df = DateFormatter()
                                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                let date = df.date(from: expiration)
                                UserDefaults.standard.bearerExpiration = date!
                                self.userClaim = .give
                                UserDefaults.standard.isLoggedIn = true
                                self.getUserExt(completionHandler: { (status) in
                                    if status {
                                        self.log.info(message: "User logged in")
                                        self.checkMandate(completionHandler: { (status) in
                                            self.userClaim = self.isFullyRegistered ? .give : .giveOnce
                                            completionHandler(true, nil, nil)
                                        })
                                    } else {
                                        self.log.warning(message: "Strange: we can log in but cannot retrieve our own user data")
                                        completionHandler(true, nil, nil)
                                    }
                                })
                            } else {
                                self.log.error(message: "Could not parse access_token/.expires field")
                                completionHandler(false, nil, nil)
                            }
                        } catch let error as NSError {
                            self.log.error(message: "Could not parse data")
                            print(error)
                            completionHandler(false, nil, nil)
                        }
                    } else {
                        if let dataString = String(data: data, encoding: String.Encoding.utf8),
                            let dict = self.convertToDictionary(text: dataString),
                            let err_description = dict["error_description"] as? String {
                            completionHandler(false, nil, err_description)
                        } else {
                            completionHandler(false, nil, nil)
                        }
                    }
                } else {
                    completionHandler(false, nil, "NoInternet")
                }
                
            }
        } catch {
            log.error(message: "Something went wrong logging in.")
        }
        
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func getUserExt(completionHandler: @escaping (Bool) -> Void) {
        client.get(url: "/api/UsersExtension", data: [:]) { (res) in
            if let res = res, let data = res.data, res.basicStatus == .ok {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    print(parsedData)
                    let newConfig = UserDefaults.standard.userExt
                    newConfig?.guid = parsedData["GUID"] as! String
                    newConfig?.mobileNumber = parsedData["PhoneNumber"] as! String
                    newConfig?.firstName = parsedData["FirstName"] as! String
                    newConfig?.lastName = parsedData["LastName"] as! String
                    newConfig?.email = parsedData["Email"] as! String
                    newConfig?.address = parsedData["Address"] as! String
                    newConfig?.postalCode = parsedData["PostalCode"] as! String
                    newConfig?.city = parsedData["City"] as! String
                    newConfig?.countryCode = String(describing: parsedData["CountryCode"] as! Int)
                    newConfig?.iban = parsedData["IBAN"] as! String
                    UserDefaults.standard.userExt = newConfig
                    UserDefaults.standard.amountLimit = (parsedData["AmountLimit"] != nil && parsedData["AmountLimit"] as! Int == 0) ? 500 : parsedData["AmountLimit"] as! Int
                    completionHandler(true)
                } catch let err as NSError {
                    completionHandler(false)
                    print(err)
                }
            } else {
                completionHandler(false)
            }
        }
    }
    
    func registerUser(_ user: RegistrationUser) {
        _registrationUser = UserExt()
        _registrationUser.firstName = user.firstName
        _registrationUser.lastName = user.lastName
        _registrationUser.password = user.password
        _registrationUser.email = user.email
    }
    
    func registerExtraDataFromUser(_ user: RegistrationUserData, completionHandler: @escaping (Bool) -> Void) {
        _registrationUser.address = user.address
        _registrationUser.city = user.city
        _registrationUser.countryCode = user.countryCode
        _registrationUser.mobileNumber = user.mobileNumber
        _registrationUser.iban = user.iban.replacingOccurrences(of: " ", with: "")
        _registrationUser.postalCode = user.postalCode
        
        //TODO: checkTLD
        
        do {
            try client.post(url: "/api/Users", data: ["email":_registrationUser.email,"password":_registrationUser.password]) { (res) in
                if let res = res, let data = res.data {
                    self._registrationUser.guid = String(bytes: data, encoding: .utf8)!
                    let newConfig = UserDefaults.standard.userExt!
                    newConfig.guid = self._registrationUser.guid
                    UserDefaults.standard.userExt = newConfig
                    
                    self.registerAllData(completionHandler: { success in
                        if success {
                            _ = self.loginUser(email: self._registrationUser.email, password: self._registrationUser.password, completionHandler: { (success, err, descr) in
                                
                                if success {
                                    if self._registrationUser.iban == AppConstants.tempIban.replacingOccurrences(of: " ", with: "") {
                                        
                                    }
                                    
                                    self._registrationUser.password = ""
                                    UserDefaults.standard.userExt = self._registrationUser
                                    self.saveAmountLimit(500, completionHandler: { (status) in
                                        //niets
                                    })
                                    UserDefaults.standard.amountLimit = 500
                                    completionHandler(true)
                                } else {
                                    completionHandler(false)
                                }
                            })
                        } else {
                            completionHandler(false)
                        }
                    })
                    
                } else {
                    completionHandler(false)
                }
            }
        } catch {
            log.error(message: "Something went wrong creating extra data")
        }
        
        
    }
    
    func registerAllData(completionHandler: @escaping (Bool) -> Void) {
        let params = [
            "Email": _registrationUser.email,
            "Guid":  _registrationUser.guid,
            "IBAN":  _registrationUser.iban,
            "PhoneNumber":  _registrationUser.mobileNumber,
            "FirstName":  _registrationUser.firstName,
            "LastName":  _registrationUser.lastName,
            "Address":  _registrationUser.address,
            "City":  _registrationUser.city,
            "PostalCode":  _registrationUser.postalCode,
            "CountryCode":  _registrationUser.countryCode,
            "AmountLimit": "500"]
        
        do {
            try client.post(url: "/api/UsersExtension", data: params) { (res) in
                if res != nil {
                    self.log.info(message: "user succesfully registered")
                    completionHandler(true)
                } else {
                    self.log.info(message: "not able to store extra data")
                    completionHandler(false)
                }
            }
        } catch {
            log.error(message: "Something went wrong trying to register all user data")
        }
        
        
    }
    
    func requestMandateUrl(mandate: Mandate, completionHandler: @escaping (String?) -> Void) {
        do {
            try client.post(url: "/api/Mandate", data: mandate.toDictionary()) { (response) in
                if let response = response, let text = response.text {
                    if response.basicStatus == .ok {
                        completionHandler(text)
                    } else {
                        completionHandler(nil)
                        self.log.error(message: text)
                    }
                } else {
                    completionHandler(nil)
                }
            }
        } catch {
            log.error(message: "Something wrong requesting mandate url")
        }
        
    }
    
    func finishMandateSigning(completionHandler: @escaping (Bool) -> Void) {
        var idx: Int = 0
        var res:String  = ""
        for i in 0...20 {
            idx = i
            
            checkMandate(completionHandler: { (str) in
                res = str
                print(res)
            })
            
            usleep(40000)
            
            if !res.isEmpty() && res.split(separator: ".")[0]  == "closed" {
                print("skip")
                break
            }
            usleep(500000)
        }
        completionHandler(idx != 20 && UserDefaults.standard.mandateSigned)
    }
    
    func checkMandate(completionHandler: @escaping (String) -> Void) {
        let data = ["UserID" : (UserDefaults.standard.userExt?.guid)!]
        client.get(url: "/api/Mandate", data: data) { (response) in
            if let temp = response, let data = temp.data, temp.basicStatus == .ok {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    UserDefaults.standard.mandateSigned = (parsedData["Signed"] != nil && parsedData["Signed"] as! Int == 1)
                    self.log.info(message: "Mandate signed: " + String(UserDefaults.standard.mandateSigned))
                    if let status = parsedData["PayProvMandateStatus"] as? String {
                        completionHandler(status)
                    } else {
                        self.log.error(message: "Could not extract PayProvMandateStatus from JSON Object")
                        completionHandler("")
                    }
                } catch {
                    self.log.error(message: "Could not parse mandate. Json probably not valid.")
                    completionHandler("")
                }
            } else {
                completionHandler("")
            }
        }
    }
    
    func registerEmailOnly(email: String, completionHandler: @escaping (Bool) -> Void) {
        let regUser = RegistrationUser(email: email, password: AppConstants.tempUserPassword, firstName: "John", lastName: "Doe")
        let regUserExt = RegistrationUserData(address: "Foobarstraat 5", city: "Foobar", countryCode: "NL", iban: AppConstants.tempIban, mobileNumber: "0600000000", postalCode: "786 FB")
        self.registerUser(regUser)
        self.registerExtraDataFromUser(regUserExt) { b in
            if b {
                self.userClaim = .giveOnce
                UserDefaults.standard.isLoggedIn = true
                DispatchQueue.main.async { UIApplication.shared.applicationIconBadgeNumber = 1 }
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    func checkTLD(email: String, completionHandler: @escaping (Bool) -> Void) {
        LogService.shared.info(message: "Checking TLD for email " + email)
        client.get(url: "/api/CheckTLD", data: ["email" : email]) { (status) in
            if let temp = status, let text = temp.text, temp.basicStatus == .ok {
                let b: Bool = NSString(string: text).boolValue
                
                completionHandler(b)
            } else {
                LogService.shared.error(message: "Could not check TLD")
                completionHandler(false)
            }
        }
    }
    
    func doesEmailExist(email: String, completionHandler: @escaping (String) -> Void) {
        self.log.info(message: "Checking if email exists")
        client.get(url: "/api/Users/Check", data: ["email" : email]) { (status) in
            if let temp = status, let text = temp.text, temp.basicStatus == .ok {
                var userExt = UserExt()
                if let settings = UserDefaults.standard.userExt {
                    userExt = settings
                }
                userExt.email = email
                UserDefaults.standard.userExt = userExt
                let s = text.replacingOccurrences(of: "\"", with: "")
                completionHandler(s)
            } else {
                self.log.error(message: "Could not check wether email exists")
                completionHandler("")
            }
        }
    }
    
    func sendSupport(text: String, completionHandler: @escaping (Bool) -> Void) {
        self.log.info(message: "Sending a message to support")
        let params = ["Guid" : UserDefaults.standard.userExt.guid, "Message" : text, "Subject" : "Feedback app"]
        do {
            try client.post(url: "/api/SendSupport", data: params) { (success) in
                completionHandler((success != nil))
            }
        } catch {
            log.error(message: "Something went wrong sending a message to support")
        }
        
    }
    
    func terminateAccount(completionHandler: @escaping (Bool) -> Void) {
        self.log.info(message: "Terminating account")
        do {
            try client.post(url: "/api/users/unregister", data: [:]) { (status) in
                if (status != nil) {
                    self.logout()
                    completionHandler(true)
                } else {
                    self.log.error(message: "Could not terminate account")
                    completionHandler(false)
                }
            }
        } catch {
            log.error(message: "Something went wrong terminating account")
        }
        
    }
    
    func registerPin(pin: String, completionHandler: @escaping (Bool) -> Void) {
        self.log.info(message: "Setting pin")
        do {
            try client.put(url: "/api/Users/Pin", data: ["PinHash" : pin]) { (res) in
                if let res = res, res.basicStatus == .ok {
                    completionHandler(true)
                } else {
                    self.log.error(message: "Could not set pin")
                    completionHandler(false)
                }
            }
        } catch {
            log.error(message: "Something went wrong registering the pin")
        }
        
    }
    
    func changeIban(iban: String, callback: @escaping (Bool) -> Void) {
        self.log.info(message: "Changing iban")
        if let settings = UserDefaults.standard.userExt {
            let params = [
                "Guid":  settings.guid,
                "IBAN":  iban,
                "PhoneNumber":  settings.mobileNumber,
                "FirstName":  settings.firstName,
                "LastName":  settings.lastName,
                "Address":  settings.address,
                "City":  settings.city,
                "PostalCode":  settings.postalCode,
                "CountryCode":  settings.countryCode,
                "AmountLimit" : String(UserDefaults.standard.amountLimit)]
            
            do {
                
                try client.put(url: "/api/UsersExtension", data: params, callback: { (res) in
                    if let res = res, res.basicStatus == .ok {
                        settings.iban = iban
                        UserDefaults.standard.userExt = settings
                        callback(true)
                    } else {
                        callback(false)
                    }
                })
            } catch {
                callback(false)
                log.error(message: "Something went wrong trying to change IBAN")
            }
        }
        
    }
    
    func requestNewPassword(email: String, callback: @escaping (Bool) -> Void) {
        do {
            try client.post(url: "/api/v2/Users/ForgotPassword?email=" + email.RFC3986UnreservedEncoded, data: [:], callback: { (response) in
                if let response = response {
                    if response.basicStatus == .ok {
                        callback(true)
                    } else {
                        callback(false)
                    }
                } else {
                    callback(false)
                }
            })
        } catch {
            callback(false)
        }
    }
    
    func resume() {
        if !UserDefaults.standard.mandateSigned {
            self.checkMandate(completionHandler: { (status) in
                self.userClaim = self.isFullyRegistered ? .give : .giveOnce
            })
        } else {
            self.userClaim = .give
        }
        
    }
    
    func logout() {
        self.log.info(message: "App settings got cleared by either terminate account/switch account")
        UserDefaults.standard.viewedCoachMarks = 0
        UserDefaults.standard.amountLimit = 0
        UserDefaults.standard.bearerToken = ""
        UserDefaults.standard.isLoggedIn = false
        userClaim = .startedApp
        UserDefaults.standard.userExt = UserExt()
        UserDefaults.standard.bearerExpiration = Date()
        UserDefaults.standard.mandateSigned = false
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults.standard.hasTappedAwayGiveDiff = false
        UserDefaults.standard.hasPinSet = false
    }
}
