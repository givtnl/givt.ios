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

class APIClient: NSObject, URLSessionDelegate {
    static let shared = APIClient(url: AppConstants.apiUri)
    static let cloud = APIClient(url: AppConstants.cloudApiUri)
    private var log = LogService.shared
    
    private var BASEURL: String
    private var client: Client
    
    init(url: String) {
        self.BASEURL = url
        client = Client().baseUrl(url: url)
    }
    
    func get(url: String, data: [String: String], headers: [String: String] = [:], timeout: Double = 60, callback: @escaping (Response?) -> Void, retryCount: Int = 0) {
        var headers = headers
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        if url != "/api/v2/status" {
            log.info(message: "GET on " + url)
        }
        
        var retries = retryCount
        
        client.get(url: url).delegate(delegate: self)
            .type(type: "json")
            .timeout(timeout: timeout)
            .set(headers: headers)
            .query(query: data)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            self.get(url: url, data: data, headers: headers, timeout: timeout, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
            }
    }
    
    func head(url: String, headers: [String: String] = [:], timeout: Double = 60, callback: @escaping (Response?) -> Void, retryCount: Int = 0) {
        if url != "/api/v2/status" {
            log.info(message: "HEAD on " + url)
        }
        
        var retries = retryCount
        
        var headers = headers
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        
        client.head(url: url).delegate(delegate: self)
            .timeout(timeout: timeout)
            .set(headers: headers)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            self.head(url: url, timeout: timeout, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
            }
    }
    
    func put(url: String, data: [String: Any?], callback: @escaping (Response?) -> Void, retryCount: Int = 0) throws {
        log.info(message: "PUT on " + url)
        
        var retries = retryCount
        
        client.put(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: ["Authorization" : "Bearer " + UserDefaults.standard.bearerToken!, "Accept-Language" : Locale.preferredLanguages[0]])
            .send(data: data)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            try? self.put(url: url, data: data, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                print(err)
                callback(nil)
                self.handleError(err: err)
            }
    }
    
    func put(url: String, data: Data, callback: @escaping (Response?) -> Void, retryCount: Int = 0) throws {
        log.info(message: "PUT on " + url)
        
        var retries = retryCount
        
        client.put(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: ["Authorization" : "Bearer " + UserDefaults.standard.bearerToken!, "Accept-Language" : Locale.preferredLanguages[0]])
            .send(data: data)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            try? self.put(url: url, data: data, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                print(err)
                callback(nil)
                self.handleError(err: err)
            }
    }
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void, retryCount:Int = 0) throws {
        log.info(message: "POST on " + url)
        var headers: [String: String] = [:]
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        var retries = retryCount
        client.post(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            try? self.post(url: url, data: data, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
            }
    }
    
    func post(url: String, data: Data, callback: @escaping (Response?) -> Void, retryCount: Int = 0) throws {
        log.info(message: "POST on " + url)
        var headers: [String: String] = [:]
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        var retries = retryCount
        client.post(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            try? self.post(url: url, data: data, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
            }
    }
    
    func delete(url: String, data: [Any], callback: @escaping (Response?) -> Void, retryCount: Int = 0) {
        log.info(message: "DELETE ON " + url)
        var headers: [String: String] = [:]
        headers["Accept-Language"] = Locale.preferredLanguages[0]
        guard let bearerToken = UserDefaults.standard.bearerToken
        else {
            callback(nil)
            return
        }
        var retries = retryCount
        headers["Authorization"] = "Bearer " + bearerToken
        client.delete(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data).end(done: { (response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            self.delete(url: url, data: data, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (error) in
                callback(nil)
                self.handleError(err: error)
            }
    }
    
    func patch(url: String, callback: @escaping (Response?) -> Void, retryCount: Int = 0) {
        var headers: [String: String] = [:]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        log.info(message: "PATCH on " + url)
        
        var retries = retryCount
        
        client.patch(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            self.patch(url: url, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
            }
    }
    
    func patch(url: String, data: Data, callback: @escaping (Response?) -> Void, retryCount: Int = 0) {
        var headers: [String: String] = [:]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        log.info(message: "PATCH on " + url)
        
        var retries = retryCount
        
        client.patch(url: url).delegate(delegate: self)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data)
            .end(done: { (response:Response) in
                if response.status == .tooManyRequests {
                    if retries < 5 {
                        let waitTime = self.getExponentialBackoffTime(retries: retries)
                        retries += 1
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(waitTime)) {
                            self.patch(url: url, data: data, callback: callback, retryCount: retries)
                        }
                    }
                } else {
                    callback(response)
                }
            }) { (err) in
                callback(nil)
                self.handleError(err: err)
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
    
    fileprivate func getExponentialBackoffTime(retries: Int) -> Int {
        let miliSecondsToWait = 100
        let powedWaitTime = pow(2.decimal, retries).int * miliSecondsToWait
        return powedWaitTime
    }
}
