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
import LocalAuthentication
import CoreTelephony
import Mixpanel

class LoginManager {
    
    private var client: APIClient = APIClient.shared
    private var authClient: AuthClient = AuthClient.shared
    private var log: LogService = LogService.shared
    
    enum AuthenticationType {
        case password
        case pincode
        case fingerprint
    }
    
    enum UserClaims: Int {
        case startedApp
        case giveOnce
        case give
    }
    
    static let shared = LoginManager()
    
    private init() {
        userClaim = UserDefaults.standard.isLoggedIn && !(UserDefaults.standard.userExt?.guid ?? "").isEmpty ? .give : .startedApp
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
            return UserDefaults.standard.mandateSigned && UserDefaults.standard.amountLimit != .max && UserDefaults.standard.amountLimit != -1
        }
    }
    
    public var isUserLoggedIn: Bool {
        get { return UserDefaults.standard.isLoggedIn }
    }
    
    public var isBearerStillValid: Bool {
        if let bearerToken = UserDefaults.standard.bearerToken, Date() < UserDefaults.standard.bearerExpiration && !bearerToken.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    public func loginUser(email: String, password: String, type: AuthenticationType, completionHandler: @escaping (Bool, String?) -> Void ) {
        var params: [String : String] = [:]
        switch type {
        case .fingerprint:
            params = ["grant_type":"fingerprint","userName":email,"fingerprint":password]
        case .pincode:
            params = ["grant_type":"pincode","userName":email,"pincode":password]
        case .password:
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
                            if let accessToken = parsedData["access_token"] as? String, let expiration = parsedData[".expires"] as? String, let guid = parsedData["GUID"] as? String {
                                UserDefaults.standard.bearerToken = accessToken
                                let df = DateFormatter()
                                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                df.locale = Locale(identifier: "en_US_POSIX") as Locale
                                df.timeZone = TimeZone(secondsFromGMT: 0)!
                                let date = df.date(from: expiration)
                                UserDefaults.standard.bearerExpiration = date!
                                self.userClaim = .give
                                UserDefaults.standard.isLoggedIn = true
                                
                                var config: UserExt = UserExt()
                                if let oldConfig = UserDefaults.standard.userExt {
                                    config = oldConfig
                                }
                                config.guid = guid
                                config.email = email
                              
                                UserDefaults.standard.userExt = config

                                Mixpanel.mainInstance().identify(distinctId: config.guid)

                                GivtManager.shared.getBeaconsFromOrganisation(completionHandler: { (status) in
                                    //do nothing
                                })
                            
                                self.getUserExt(completion: { (obj) in
                                    if obj != nil {
                                        if (try? Mediater.shared.send(request: GetCountryQuery())) == "US" {
                                            UserDefaults.standard.paymentType = .CreditCard
                                            if (try? Mediater.shared.send(request: GetUserHasDonations(userId: guid))) ?? false {
                                                self.userClaim = self.isFullyRegistered ? .give : .giveOnce
                                                !self.isFullyRegistered ? BadgeService.shared.addBadge(badge: .completeRegistration) : BadgeService.shared.removeBadge(badge: .completeRegistration)
                                            } else {
                                                self.userClaim = .giveOnce
                                                BadgeService.shared.removeBadge(badge: .completeRegistration)
                                            }
                                        } else {
                                            self.userClaim = self.isFullyRegistered ? .give : .giveOnce
                                            !self.isFullyRegistered ? BadgeService.shared.addBadge(badge: .completeRegistration) : BadgeService.shared.removeBadge(badge: .completeRegistration)
                                        }
                                    } else {
                                        self.log.warning(message: "Strange: we can log in but cannot retrieve our own user data")
                                    }
                                    self.log.info(message: "User logged in")
                                    NotificationCenter.default.post(name: .GivtUserDidLogin, object: nil)
                                    
                                    completionHandler(true, nil)
                                })
                            } else {
                                self.log.error(message: "Could not parse access_token/.expires field")
                                completionHandler(false, nil)
                            }
                        } catch let error as NSError {
                            self.log.error(message: "Could not parse data")
                            print(error)
                            completionHandler(false, nil)
                        }
                    } else if temp.basicStatus == .serverError {
                        self.log.error(message: "Server error when trying to log in. Timeout? Microsoft 🙃")
                        completionHandler(false, "ServerError")
                    } else {
                        if let dataString = String(data: data, encoding: String.Encoding.utf8),
                            let dict = self.convertToDictionary(text: dataString),
                            let err_description = dict["error_description"] as? String {
                            completionHandler(false, err_description)
                        } else {
                            completionHandler(false, nil)
                        }
                    }
                } else {
                    completionHandler(false, "NoInternet")
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

    func getUserExt(completion: @escaping(LMUserExt?) -> Void) {
        client.get(url: "/api/UsersExtension", data: [:]) { (response) in
            guard let response = response else {
                completion(nil)
                self.log.error(message: "No response from getting UserExt object")
                return
            }
            
            if response.status == .ok {
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
                        let userExt = try decoder.decode(LMUserExt.self, from: data)
                        UserDefaults.standard.isTempUser = userExt.IsTempUser
                        UserDefaults.standard.amountLimit = userExt.AmountLimit == 0 ? 499 : userExt.AmountLimit
                        UserDefaults.standard.mandateSigned = userExt.PayProvMandateStatus == "closed.completed"
                        if let accountType = AccountType(rawValue: userExt.AccountType.lowercased()),
                           accountType != .undefined {
                            UserDefaults.standard.paymentType = PaymentType.fromAccountType(accountType)
                        }
                        UserDefaults.standard.giftAidEnabled = userExt.GiftAidEnabled
                        AppServices.shared.setLocale()
                        if let newConfig = UserDefaults.standard.userExt {
                            newConfig.country = userExt.Country
                            UserDefaults.standard.userExt = newConfig
                        }
                        completion(userExt)
                    } catch let err as NSError {
                        self.log.error(message: err.description)
                        completion(nil)
                    }
                }
            } else {
                self.log.error(message: "Status was NOT ok from getting UserExt object")
                completion(nil)
            }
        }
    }
    
    func registerFingerprint(fingerprint: String, completion: @escaping (Bool) -> Void) {
        let params = ["Fingerprint" : fingerprint]
        do {
            try client.put(url: "/api/v2/Users/Fingerprint", data: params, callback: { (response) in
                if let r = response {
                    if r.basicStatus == .ok {
                        UserDefaults.standard.hasFingerprintSet = true
                        completion(true)
                    } else {
                        print(r.text!)
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            })
        } catch {
            print("err")
        }
    }
    
    func registerExtraDataFromUser(_ user: RegistrationUser, completionHandler: @escaping (Bool?) -> Void) {
        var params = [
            "Email": user.email,
            "Password" : user.password,
            "PhoneNumber":  user.mobileNumber,
            "FirstName":  user.firstName,
            "LastName":  user.lastName,
            "Address":  user.address,
            "City":  user.city,
            "PostalCode":  user.postalCode,
            "Country":  user.country,
            "AmountLimit": "499",
            "TimeZoneId": user.timeZoneId]
        
        if !user.iban.isEmpty {
            params["IBAN"] = user.iban.replacingOccurrences(of: " ", with: "")
        } else {
            params["SortCode"] = user.sortCode
            params["AccountNumber"] = user.bacsAccountNumber
        }
        
        if let langCode = Locale.current.languageCode {
            params["AppLanguage"] = langCode
        } else {
            self.log.warning(message: "Device has no languagecode... Default EN") //TODO: when changing default lang, change this to "en"
            params["AppLanguage"] = "en"
        }
        do {
            try client.post(url: "/api/v2/Users", data: params) { (res) in
                if let res = res {
                    if let data = res.data, res.basicStatus == .ok {
                        let guid = String(bytes: data, encoding: .utf8)!
                        let newConfig = UserDefaults.standard.userExt!
                        newConfig.guid = guid
                        UserDefaults.standard.userExt = newConfig
                        self.loginUser(email: user.email, password: user.password, type: .password, completionHandler: { (success, descr) in
                            if success {
                                if let limit = params["AmountLimit"] {
                                    UserDefaults.standard.amountLimit = Int(limit) ?? 499
                                }
                                completionHandler(true)
                            } else {
                                self.log.info(message: "Login failed")
                                completionHandler(false)
                            }
                        })
                    } else {
                        //got a response but was not OK
                        if res.statusCode == 409 {
                            self.log.error(message: "User wants to register but is stuck in registration flow. (409)")
                        } else {
                            self.log.info(message: "Not able to register the user")
                        }
                        completionHandler(false)
                    }
                    
                } else {
                    self.log.info(message: "Not able to register the user (no response from server)")
                    completionHandler(nil)
                }
            }
        } catch {
            log.error(message: "Something went wrong creating extra data")
            completionHandler(nil)
        }
    }
    
    func changeGiftAidEnabled(giftaidEnabled: Bool, completionHandler: @escaping (Bool) -> Void) {
        do {
            let params = ["authorised" : giftaidEnabled]
            try client.post(url: "/api/v2/users/" + UserDefaults.standard.userExt!.guid + "/giftaidauthorisations", data: params, callback: { (res) in
                if let res = res {
                    completionHandler(true)
                    self.log.info(message: "updated the giftaidShizzle")
                } else {
                    self.log.info(message: "not updated the giftaidShizzle")
                    completionHandler(false)
                }
            })
        } catch {
            self.log.info(message: "not updated the giftaidShizzle")
            completionHandler(false)
        }
    }
    
    func registerMandate(completionHandler: @escaping (Response?) -> Void) {
        do {
            var localeQuerystring = ""
            if let langCode = Locale.current.languageCode {
                localeQuerystring = "?locale=" + langCode
            }
            try client.post(url: "/api/v2/users/" + UserDefaults.standard.userExt!.guid + "/mandates" + localeQuerystring, data: [:], callback: { (response) in
                completionHandler(response)
            })
        } catch {
            self.log.error(message: "Could not sign mandate")
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
        if UserDefaults.standard.paymentType == .CreditCard {
            self.log.info(message: "Mandate signed: " + String(UserDefaults.standard.mandateSigned))
            !self.isFullyRegistered && UserDefaults.standard.yearsWithGivts.count > 0 ? BadgeService.shared.addBadge(badge: .completeRegistration) : BadgeService.shared.removeBadge(badge: .completeRegistration)
            completionHandler("No mandates for credit card, so trick the system we are signed")
            return
        }
        
        if let user = UserDefaults.standard.userExt {
            let data = ["UserID" : user.guid]
            client.get(url: "/api/Mandate", data: data) { (response) in
                if let temp = response, let data = temp.data, temp.basicStatus == .ok {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                        UserDefaults.standard.mandateSigned = (parsedData["Signed"] != nil && parsedData["Signed"] as! Int == 1)
                        self.log.info(message: "Mandate signed: " + String(UserDefaults.standard.mandateSigned))
                        if (try? Mediater.shared.send(request: GetCountryQuery())) == "US" {
                            if (try? Mediater.shared.send(request: GetUserHasDonations(userId: user.guid))) ?? false {
                                !self.isFullyRegistered ? BadgeService.shared.addBadge(badge: .completeRegistration) : BadgeService.shared.removeBadge(badge: .completeRegistration)
                            } else {
                                BadgeService.shared.removeBadge(badge: .completeRegistration)
                            }
                        } else {
                            !self.isFullyRegistered ? BadgeService.shared.addBadge(badge: .completeRegistration) : BadgeService.shared.removeBadge(badge: .completeRegistration)
                        }
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
    }
    
    func registerEmailOnly(email: String, completionHandler: @escaping (Bool) -> Void) {
        let regUser = RegistrationUser(email: email, password: AppConstants.tempUserPassword, firstName: "John", lastName: "Doe", address: "Foobarstraat 5", city: "Foobar", country: "NL", iban: AppConstants.tempIban, mobileNumber: "0600000000", postalCode: "786 FB", sortCode: "", bacsAccountNumber: "", timeZoneId: TimeZone.current.identifier)
        
        if let countryCode = try? Mediater.shared.send(request: GetCountryQuery()) {
            regUser.country = countryCode
            if countryCode == "US" {
                UserDefaults.standard.paymentType = .CreditCard
            }
        }
        
        self.registerExtraDataFromUser(regUser) { b in
            if let b = b {
                if b {
                    self.userClaim = .giveOnce
                    UserDefaults.standard.isLoggedIn = true
                    var config: UserExt = UserExt()
                    if let oldConfig = UserDefaults.standard.userExt {
                        config = oldConfig
                    }
                    config.isTemp = true
                    UserDefaults.standard.userExt = config
                    UserDefaults.standard.isTempUser = config.isTemp
                    if regUser.country != "US" { BadgeService.shared.addBadge(badge: .completeRegistration) }
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
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
    
    // Used to update the email address, amountlimit and the giftaid
    func updateUser(uext: LMUserExt, completionHandler: @escaping (Bool) -> Void) {
        do {
            let params = ["Email": uext.Email, "AmountLimit": uext.AmountLimit, "GiftAidEnabled": uext.GiftAidEnabled] as [String : Any]
            try client.post(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)/", data: params) { (response) in
                guard let resp = response else {
                    completionHandler(false)
                    return
                }
                if resp.statusCode == 200 {
                    let newSettings = UserDefaults.standard.userExt!
                    newSettings.email = uext.Email
                    UserDefaults.standard.amountLimit = uext.AmountLimit
                    UserDefaults.standard.giftAidEnabled = uext.GiftAidEnabled
                    UserDefaults.standard.userExt = newSettings
                    completionHandler(true)
                } else {
                    LogService.shared.error(message: "Could not update email")
                    completionHandler(false)
                }
            }
        } catch {
            LogService.shared.error(message: "Could not update email")
            completionHandler(false)
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
                if userExt.email != email {
                    UserDefaults.standard.hasPinSet = false
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
        let params = ["Guid" : UserDefaults.standard.userExt!.guid, "Message" : text, "Subject" : "Feedback app"]
        do {
            try client.post(url: "/api/SendSupport", data: params) { (success) in
                completionHandler((success != nil))
            }
        } catch {
            log.error(message: "Something went wrong sending a message to support")
        }
        
    }
    
    func terminateAccount(completionHandler: @escaping (String?) -> Void) {
        self.log.info(message: "Terminating account")
        var errorTerm = "UnregisterError"
        do {
            try client.post(url: "/api/users/unregister", data: [:]) { (unregisterResponse) in
                if (unregisterResponse != nil) {
                    if let statusCode = unregisterResponse?.statusCode {
                        if statusCode >= 300
                        {
                            guard let data = unregisterResponse?.data else { completionHandler(errorTerm); return }
                            do {
                                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                if let additionalInformation = parsedData["AdditionalInformation"] as? Dictionary<String, Any>,
                                    let responseErrorTerm = additionalInformation["errorTerm"] as? String {
                                    errorTerm = responseErrorTerm
                                }
                                DispatchQueue.main.async { completionHandler(errorTerm) }
                            } catch { completionHandler(errorTerm) }
                        } else {
                            completionHandler(nil)
#if !PRODUCTION
                            UserDefaults.standard.hackForTesting = false
#endif
                            self.logout()
                        }
                    }
                } else {
                    self.log.error(message: "Could not terminate account")
                    completionHandler(errorTerm)
                }
            }
        } catch {
            log.error(message: "Something went wrong terminating account")
            completionHandler(errorTerm)
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

    internal class UserExtUpdateResult {
        var ok: Bool = false
        var error: Int = -1
    }

    func updateUserExt(userExt: LMUserExt, callback: @escaping (UserExtUpdateResult) -> Void) {
        self.log.info(message: "Updating user extension")
        let params = [
            "Guid":  userExt.GUID,
            "IBAN":  userExt.IBAN as Any,
            "AccountNumber" : userExt.AccountNumber as Any,
            "SortCode" : userExt.SortCode as Any,
            "PhoneNumber":  userExt.PhoneNumber,
            "FirstName":  userExt.FirstName,
            "LastName":  userExt.LastName,
            "Address":  userExt.Address,
            "City":  userExt.City,
            "PostalCode":  userExt.PostalCode,
            "Country":  userExt.Country,
            "GiftAidEnabled": userExt.GiftAidEnabled
        ]
        
        
        let result = UserExtUpdateResult()

        do {
            try client.put(url: "/api/v2/UsersExtension", data: params, callback: { (res) in
                if let response = res {
                    result.ok = response.basicStatus == .ok
                    if(!result.ok){
                        if let data = response.data {
                            do {
                                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                if let parsedCode = parsedData["Code"] as? Int {
                                    result.error = parsedCode
                                }
                            }
                            catch {
                                self.log.error(message: "Could not parse givtStatusCode Json probably not valid.")
                            }
                        }
                    }
                }
                callback(result)
            })
        } catch {
            callback(result)
            log.error(message: "Something went wrong updating UserExt")
        }
    }
    
    func loginWithFingerprint(completion: @escaping (Bool, OSStatus?) -> Void) {
        let authenticationContext = LAContext()
        var error: NSError?
        if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            var localQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrLabel as String: "Fingerprint", kSecMatchLimit as String: kSecMatchLimitOne,kSecReturnAttributes as String: true, kSecReturnData as String: true, kSecAttrAccount as String: UserDefaults.standard.userExt!.guid]
            if #available(iOS 11.0, *) {
                if authenticationContext.biometryType == .touchID {
                    localQuery[kSecUseOperationPrompt as String] = NSLocalizedString("FingerprintMessageAlert", comment: "")
                        .replacingOccurrences(of: "{0}", with: NSLocalizedString("TouchID", comment: ""))
                        .replacingOccurrences(of: "{1}", with: UserDefaults.standard.userExt!.email)
                } else if authenticationContext.biometryType == .faceID {
                    localQuery[kSecUseOperationPrompt as String] = NSLocalizedString("FingerprintMessageAlert", comment: "")
                        .replacingOccurrences(of: "{0}", with: NSLocalizedString("FaceID", comment: ""))
                        .replacingOccurrences(of: "{1}", with: UserDefaults.standard.userExt!.email)
                }
            } else {
                // Fallback on earlier versions
                localQuery[kSecUseOperationPrompt as String] = NSLocalizedString("FingerprintMessageAlert", comment: "")
                    .replacingOccurrences(of: "{0}", with: NSLocalizedString("TouchID", comment: ""))
                    .replacingOccurrences(of: "{1}", with: UserDefaults.standard.userExt!.email)
            }
            
            var item: CFTypeRef?
            let status = SecItemCopyMatching(localQuery as CFDictionary, &item)
            
            if status == errSecSuccess {
                guard let existingItem = item as? [String : Any],
                    let passwordData = existingItem[kSecValueData as String] as? Data,
                    let password = String(data: passwordData, encoding: String.Encoding.utf8)
                    else {
                        self.log.warning(message: "Fingerprint password is gone")
                        UserDefaults.standard.hasFingerprintSet = false
                        completion(false, status)
                        return
                }
                self.loginUser(email: UserDefaults.standard.userExt!.email, password: password, type: LoginManager.AuthenticationType.fingerprint, completionHandler: { (success, str) in
                    if success {
                        self.log.info(message: "Succesfully logged in with biometrics")
                        completion(true, status)
                    } else {
                        self.log.info(message: "Could not log in using biometrics. Defaulting to passcode/password")
                        UserDefaults.standard.hasFingerprintSet = false
                        completion(false, status)
                    }
                })
            } else {
                completion(false, status)
                
            }
        } else {
            completion(false, nil)
        }
    }
    
    func requestNewPassword(email: String, callback: @escaping (Bool?) -> Void) {
        do {
            try client.post(url: "/api/v2/Users/ForgotPassword?email=" + email.RFC3986UnreservedEncoded, data: [:], callback: { (response) in
                if let response = response {
                    if response.basicStatus == .ok {
                        callback(true)
                    } else {
                        callback(false)
                    }
                } else {
                    callback(nil)
                }
            })
        } catch {
            callback(nil)
        }
    }
    
    func resume() {
        if self.userClaim == UserClaims.startedApp {
            return
        }
        
        self.checkMandate(completionHandler: { (status) in
            self.userClaim = self.isFullyRegistered ? .give : .giveOnce
        })
        
        if let userId = UserDefaults.standard.userExt?.guid {
            Mixpanel.mainInstance().identify(distinctId: userId)
        }
    }
    
    func logout() {
        self.log.info(message: "App settings got cleared by either terminate account/switch account")
        UserDefaults.standard.viewedCoachMarks = 0
        UserDefaults.standard.amountLimit = 0
        UserDefaults.standard.bearerToken = ""
        UserDefaults.standard.isLoggedIn = false
        userClaim = .startedApp
        UserDefaults.standard.bearerExpiration = Date()
        UserDefaults.standard.mandateSigned = false
        BadgeService.shared.removeAllBadges()
        UserDefaults.standard.hasTappedAwayGiveDiff = false
        UserDefaults.standard.showedLastYearTaxOverview = false
        UserDefaults.standard.hasGivtsInPreviousYear = false
        UserDefaults.standard.lastGivtToOrganisationNamespace = nil
        UserDefaults.standard.lastGivtToOrganisationName = nil
        UserDefaults.standard.isTempUser = false
        UserDefaults.standard.accountType = .undefined
        UserDefaults.standard.paymentType = .Undefined
        UserDefaults.standard.hasDonations = nil
        GivtManager.shared.clearMinimumAmount()
#if !PRODUCTION
        UserDefaults.standard.hackForTesting = false
#endif
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
