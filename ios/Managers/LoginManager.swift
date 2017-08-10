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
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
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
    
    public func loginUser(email: String, password: String, completionHandler: @escaping (Bool?, NSError?) -> Void ) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "https://givtapidebug.azurewebsites.net/oauth2/token")!)
        request.httpMethod = "POST"
        let postString = "grant_type=password&userName=" + email + "&password=" + password
        request.httpBody = postString.data(using: .utf8)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: request) { data, response, error -> Void in
            if error != nil {
                // If there is an error in the web request, print it to the console
                // println(error.localizedDescription)
                completionHandler(nil, error! as NSError)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                completionHandler(false, nil)
                return
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            do
            {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let currentData = parsedData
                print(parsedData["access_token"]!)
                if(parsedData["access_token"] != nil) {
                    UserDefaults.standard.bearerToken = parsedData["access_token"]! as! String
                    UserDefaults.standard.bearerExpiration = parsedData[".expires"]! as! Date
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
}
