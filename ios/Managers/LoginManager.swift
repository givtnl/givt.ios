
//
//  LoginManager.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit
class LoginManager {
    
    enum UserClaims: Int {
        case startedApp
        case giveOnce
        case give
    }
    
    static let shared = LoginManager()
    private var _registrationUser = UserExt()
    
    
    private init() {
        print("loginmanager is created")
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
        return Date() < UserDefaults.standard.bearerExpiration
    }
    
    private var _baseUrl = "https://givtapidebug.azurewebsites.net"
    
    public func saveAmountLimit(_ amountLimit: Int, completionHandler: @escaping (Bool?, NSError?) -> Void) {
        //post request to amount limit api
        var request = URLRequest(url: URL(string: _baseUrl + "/api/Users")!)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")
        let putString = "GUID=" + UserDefaults.standard.userExt.guid + "&AmountLimit=" + String(amountLimit)
        request.httpBody = putString.data(using: .utf8)
        let urlSession = URLSession.shared
        _ = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                print(error! as NSError)
                completionHandler(false, nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print(response!)
                completionHandler(false, nil)
                return
            }

            UserDefaults.standard.amountLimit = amountLimit
            completionHandler(true, nil)
            }.resume()

    }
    
    public func loginUser(email: String, password: String, completionHandler: @escaping (Bool, NSError?) -> Void ) -> URLSessionTask {
        var request = URLRequest(url: URL(string: _baseUrl + "/oauth2/token")!)
        request.httpMethod = "POST"
        let postString = "grant_type=password&userName=" + email + "&password=" + password
        request.httpBody = postString.data(using: .utf8)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                completionHandler(false, error! as NSError)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                completionHandler(false, nil)
                return
            }
            
            do
            {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                print(parsedData)
                if(parsedData["access_token"] != nil) {
                    //print(parsedData["access_token"])
                    UserDefaults.standard.bearerToken = parsedData["access_token"]! as! String
                    let strTime = parsedData[".expires"] as? String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let date = dateFormatter.date(from: strTime!)
                    UserDefaults.standard.bearerExpiration = date!
                    self.userClaim = .give
                    UserDefaults.standard.isLoggedIn = true
                    self.getUserExt(completionHandler: { (status) in
                        if status {
                            self.checkMandate(completionHandler: { (status) in
                                self.userClaim = self.isFullyRegistered ? .give : .giveOnce
                                completionHandler(true, nil)
                            })
                        } else {
                            completionHandler(true, nil)
                        }
                    })
                    return
                }
                completionHandler(false, nil)
                return
            } catch let error as NSError {
                print(error)
                completionHandler(false, nil)
                return
            }
        
        }
        task.resume()
        return task
    }
    
    private func getUserExt(completionHandler: @escaping (Bool) -> Void) {
        var request = URLRequest(url: URL(string: _baseUrl + "/api/UsersExtension")!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")
        let urlSession = URLSession.shared
        _ = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                print(error! as NSError)
                completionHandler(false)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print(response!)
                completionHandler(false)
                return
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                let newConfig = UserDefaults.standard.userExt
                newConfig.guid = parsedData["GUID"] as! String
                UserDefaults.standard.userExt = newConfig
                UserDefaults.standard.amountLimit = (parsedData["AmountLimit"] != nil && parsedData["AmountLimit"] as! Int == 0) ? -1 : parsedData["AmountLimit"] as! Int
                completionHandler(true)
            } catch let err as NSError {
                print(err)
                completionHandler(false)
                return
            }
           
        }.resume()
    }
    
    func registerUser(_ user: RegistrationUser, completionHandler: @escaping (Bool) -> Void) {
        
        _registrationUser = UserExt()
        _registrationUser.firstName = user.firstName
        _registrationUser.lastName = user.lastName
        _registrationUser.password = user.password
        _registrationUser.email = user.email
        
        //TODO: log email to log service!
        
        completionHandler(true)
    }
    
    func registerExtraDataFromUser(_ user: RegistrationUserData, completionHandler: @escaping (Bool) -> Void) {
        _registrationUser.address = user.address
        _registrationUser.city = user.city
        _registrationUser.countryCode = user.countryCode
        _registrationUser.mobileNumber = user.mobileNumber
        _registrationUser.iban = user.iban.replacingOccurrences(of: " ", with: "")
        _registrationUser.postalCode = user.postalCode
        
        //TODO: checkTLD
        var request = URLRequest(url: URL(string: _baseUrl + "/api/Users")!)
        request.httpMethod = "POST"
        let postString = "email=" + _registrationUser.email + "&password=" + _registrationUser.password
        request.httpBody = postString.data(using: .utf8)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                completionHandler(false)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 && httpStatus.statusCode != 201 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                completionHandler(false)
                return
            }
            
            self._registrationUser.guid = String(bytes: data!, encoding: .utf8)!
            let newConfig = UserDefaults.standard.userExt
            newConfig.guid = self._registrationUser.guid
            UserDefaults.standard.userExt = newConfig
            self.registerAllData(completionHandler: { success in
                if success {
                    print("user succesfully registered")
                    _ = self.loginUser(email: self._registrationUser.email, password: self._registrationUser.password, completionHandler: { (success, err) in
                        
                        if success {
                            self._registrationUser.password = ""
                            UserDefaults.standard.userExt = self._registrationUser
                            completionHandler(true)
                        } else {
                            completionHandler(false)
                        }
                    })
                }
            })
            
            
        }
        task.resume()
    }
    
    func registerAllData(completionHandler: @escaping (Bool) -> Void) {
        var request = URLRequest(url: URL(string: _baseUrl + "/api/UsersExtension")!)
        request.httpMethod = "POST"
        let postString =
                "Guid=" + _registrationUser.guid +
                "&IBAN=" + _registrationUser.iban +
                    "&PhoneNumber=" + _registrationUser.mobileNumber +
                    "&FirstName=" + _registrationUser.firstName +
                    "&LastName=" + _registrationUser.lastName +
                    "&Address=" + _registrationUser.address +
                    "&City=" + _registrationUser.city +
                    "&PostalCode=" + _registrationUser.postalCode +
                    "&CountryCode=" + _registrationUser.countryCode
                    
                
        request.httpBody = postString.data(using: .utf8)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 && httpStatus.statusCode != 201 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                return
            }
            completionHandler(true)
        }
        task.resume()
    }
    
    func requestMandateUrl(mandate: Mandate, completionHandler: @escaping (String) -> Void) {
        var request = URLRequest(url: URL(string: _baseUrl + "/api/Mandate")!)
        request.httpMethod = "POST"
        
        do {
            let serialized = try JSONSerialization.data(withJSONObject: mandate.toDictionary(), options: .prettyPrinted)
            request.httpBody = serialized
        } catch let error {
            print(error)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")

        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 && httpStatus.statusCode != 201 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                return
            }
            let returnUrl = String(bytes: data!, encoding: .utf8)!
            completionHandler(returnUrl)
        }
        task.resume()
    }
    
    func finishMandateSigning(completionHandler: @escaping (Bool) -> Void) {
        var idx: Int = 0
        for i in 0...20 {
            idx = i
            var res:String  = ""
            let task = checkMandate(completionHandler: { (str) in
                res = str
                print(res)
            })
            while task?.state != .completed {
                usleep(40000)
            }
            if !res.isEmpty() && res.split(separator: ".")[0]  == "closed" {
                print("skip")
                break
            }
            usleep(500000)
        }
        completionHandler(idx != 20 && UserDefaults.standard.mandateSigned)
    }
    
    func checkMandate(completionHandler: @escaping (String) -> Void) -> URLSessionTask? {
        var task: URLSessionTask?
        if isBearerStillValid {
            var request = URLRequest(url: URL(string: _baseUrl + "/api/Mandate?UserID=" + UserDefaults.standard.userExt.guid)!)
            request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            let urlSession = URLSession.shared
            
            task = urlSession.dataTask(with: request) { data, response, error -> Void in
                if error != nil {
                    completionHandler("")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 && httpStatus.statusCode != 201 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    completionHandler("")
                    return
                }
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    UserDefaults.standard.mandateSigned = (parsedData["Signed"] != nil && parsedData["Signed"] as! Int == 1)
                    //print(parsedData["PayProvMandateStatus"])
                    print(UserDefaults.standard.mandateSigned)
                    if let status = parsedData["PayProvMandateStatus"] as? String {
                        completionHandler(status)
                    } else {
                        completionHandler("")
                    }
                } catch {
                    print("error occured")
                    completionHandler("")
                }
            }
            task?.resume()
        }
        return task
    }
    
    func registerEmailOnly(email: String, completionHandler: @escaping (Bool) -> Void) {
        let regUser = RegistrationUser(email: email, password: AppConstants.tempUserPassword, firstName: "John", lastName: "Doe")
        let regUserExt = RegistrationUserData(address: "Foobarstraat 5", city: "Foobar", countryCode: "NL", iban: AppConstants.tempIban, mobileNumber: "0600000000", postalCode: "786 FB")
        self.registerUser(regUser) { b in
            if b {
                self.registerExtraDataFromUser(regUserExt) { b in
                    if b {
                        self.userClaim = .giveOnce
                        UserDefaults.standard.isLoggedIn = true
                        UserDefaults.standard.amountLimit = .max
                        DispatchQueue.main.async { UIApplication.shared.applicationIconBadgeNumber = 1 }
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
            } else {
                completionHandler(false)
            }
        }
    }
    
    func checkTLD(email: String, completionHandler: @escaping (Bool) -> Void) {
        var request = URLRequest(url: URL(string: _baseUrl + "/api/CheckTLD?email=" + email)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let urlSession = URLSession.shared
        var task: URLSessionTask?
        task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                return
            }
            let status: Bool = NSString(string: String(bytes: data!, encoding: .utf8)!).boolValue
            completionHandler(status)
        }
        task?.resume()
    }
    
    func doesEmailExist(email: String, completionHandler: @escaping (String) -> Void) {
        var request = URLRequest(url: URL(string: _baseUrl + "/api/Users/Check?email=" + email)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let urlSession = URLSession.shared
        var task: URLSessionTask?
        task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 && httpStatus.statusCode != 201 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                return
            }
            let status = String(bytes: data!, encoding: .utf8)!.replacingOccurrences(of: "\"", with: "")
            completionHandler(status)
        }
        task?.resume()
    }
    
    func logout() {
        UserDefaults.standard.viewedCoachMarks = 0
        UserDefaults.standard.amountLimit = 0
        UserDefaults.standard.bearerToken = ""
        UserDefaults.standard.isLoggedIn = false
        userClaim = .startedApp
        UserDefaults.standard.userExt = UserExt()
        UserDefaults.standard.bearerExpiration = Date()
        UserDefaults.standard.mandateSigned = false
    }
}
