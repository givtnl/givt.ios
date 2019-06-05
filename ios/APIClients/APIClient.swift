//
//  APIClient.swift
//  ios
//
//  Created by Lennie Stockman on 29/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import SwiftClient
import TrustKit

class APIClient: NSObject, IAPIClient, URLSessionDelegate {
    static let shared = APIClient()
    private var log = LogService.shared
    
    private static let BASEURL: String = AppConstants.apiUri
    private var client = Client().baseUrl(url: BASEURL)
    
    private override init() {
        
    }
   
    func get(url: String, data: [String: String], headers: [String: String] = [:], timeout: Double = 60, callback: @escaping (Response?) -> Void) {
        var headers = headers
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        if let bearerToken = UserDefaults.standard.bearerToken {
                headers["Authorization"] = "Bearer " + bearerToken
        }
        if url != "/api/v2/status" {
            log.info(message: "GET on " + url)
        }
        client.get(url: url).delegate(delegate: self)
            .type(type: "json")
            .timeout(timeout: timeout)
            .set(headers: headers)
            .query(query: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
        }
    }
    
    func put(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) throws {
        log.info(message: "PUT on " + url)
        client.put(url: url).delegate(delegate: self)
            .send(data: data)
            .type(type: "json")
            .set(headers: ["Authorization" : "Bearer " + UserDefaults.standard.bearerToken!, "Accept-Language" : Locale.preferredLanguages[0]])
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                print(err)
                callback(nil)
                self.handleError(err: err)
        }
    }
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) throws {
        log.info(message: "POST on " + url)
        var headers: [String: String] = [:]
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        client.post(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
        }
    }
    
    func post(url: String, data: Data, callback: @escaping (Response?) -> Void) throws {
        log.info(message: "POST on " + url)
        var headers: [String: String] = [:]
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        client.post(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
        }
    }
    
    func delete(url: String, data: [Any], callback: @escaping (Response?) -> Void) {
        log.info(message: "DELETE ON " + url)
        var headers: [String: String] = [:]
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        guard let bearerToken = UserDefaults.standard.bearerToken
            else {
                callback(nil)
                return
        }

        headers["Authorization"] = "Bearer " + bearerToken
        client.delete(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data).end(done: { (response) in
                callback(response)
            }) { (error) in
                callback(nil)
                self.handleError(err: error)
        }
    }
    
    private func handleError(err: Error) {
        let error = (err as NSError)
        if let url = error.userInfo["NSErrorFailingURLStringKey"] as? String, let description = error.userInfo["NSLocalizedDescription"] as? String {
            self.log.error(message: "Following call failed: " + url + "\n" + "Description: " + description)
        } else {
            self.log.error(message: "Could not extract URL from error message. Is the server online?")
        }
        
        if error.code == -999 {
            self.log.error(message: "This request has been cancelled... Probably SSL Pinning did not succeed." )
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let pinningValidator = TrustKit.sharedInstance().pinningValidator
        if !pinningValidator.handle(challenge, completionHandler: completionHandler) {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        }
    }
}
