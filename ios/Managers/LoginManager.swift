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
    
    public func loginUser(email: String, password: String) {
        var request = URLRequest(url: URL(string: "https://givtapidebug.azurewebsites.net/oauth2/token")!)
        request.httpMethod = "POST"
        let postString = "grant_type=password&userName=" + email + "&password=" + password
        request.httpBody = postString.data(using: .utf8)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            do
            {
                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                let currentData = parsedData
                print(parsedData["access_token"]!)
            } catch let error as NSError {
                print(error)
            }
            
            
        }
        task.resume()

    }
    
    public var isBearerStillValid: Bool {
        return Date() < UserDefaults.standard.bearerExpiration
    }
    
    public func saveAmountLimit(_ amountLimit: Int, completionHandler: @escaping (Bool?, NSError?) -> Void) {
        //post request to amount limit api
        var request = URLRequest(url: URL(string:"https://givtapidebug.azurewebsites.net/api/Users")!)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")
        let putString = "GUID=" + UserDefaults.standard.guid + "&AmountLimit=" + String(amountLimit)
        request.httpBody = putString.data(using: .utf8)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
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
            
            //status is 200
            UserDefaults.standard.amountLimit = amountLimit
            completionHandler(true, nil)
            let httpStatus = response as? HTTPURLResponse
            print(httpStatus?.description)
            let responseString = String(data: data!, encoding: .utf8)
            //print(responseString)
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                _ = parsedData
                print(parsedData)
                
            } catch let err as NSError {
                print(err)
                return
            }
            
            }.resume()

    }
    
    public func loginUser(email: String, password: String, completionHandler: @escaping (Bool?, NSError?) -> Void ) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "https://givtapidebug.azurewebsites.net/oauth2/token")!)
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
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            do
            {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                _ = parsedData
                print(parsedData["access_token"]!)
                if(parsedData["access_token"] != nil) {
                    UserDefaults.standard.bearerToken = parsedData["access_token"]! as! String
                    let test = "testen"
                    print(test)
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
        var request = URLRequest(url: URL(string:"https://givtapidebug.azurewebsites.net/api/UsersExtension")!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                print(error! as NSError)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print(response!)
                return
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            //print(responseString)
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                _ = parsedData
                print(parsedData["GUID"])
                UserDefaults.standard.guid = parsedData["GUID"] as! String
            } catch let err as NSError {
                print(err)
                return
            }
           
        }.resume()
    }
}
