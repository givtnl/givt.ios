//
//  LoginManager.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
class LoginManager {
    func isUserLoggedIn() -> Bool {
        return true
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
        let putString = "GUID=" + UserDefaults.standard.guid + "&AmountLimit=" + String(amountLimit)
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
    
    public func loginUser(email: String, password: String, completionHandler: @escaping (Bool?, NSError?) -> Void ) -> URLSessionTask {
        var request = URLRequest(url: URL(string: _baseUrl + "/oauth2/token")!)
        request.httpMethod = "POST"
        let postString = "grant_type=password&userName=" + email + "&password=" + password
        request.httpBody = postString.data(using: .utf8)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                completionHandler(nil, error! as NSError)
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
                if(parsedData["access_token"] != nil) {
                    UserDefaults.standard.bearerToken = parsedData["access_token"]! as! String
                    let strTime = parsedData[".expires"] as? String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let date = dateFormatter.date(from: strTime!)
                    UserDefaults.standard.bearerExpiration = date!
                    self.getUserExt()
                    completionHandler(true, nil)
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
    
    private func getUserExt() {
        var request = URLRequest(url: URL(string: _baseUrl + "/api/UsersExtension")!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")
        let urlSession = URLSession.shared
        _ = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                print(error! as NSError)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print(response!)
                return
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                UserDefaults.standard.guid = parsedData["GUID"] as! String
                UserDefaults.standard.amountLimit = parsedData["AmountLimit"] != nil ? parsedData["AmountLimit"] as! Int : 5
            } catch let err as NSError {
                print(err)
                return
            }
           
        }.resume()
    }
}
