//
//  APIClient.swift
//  ios
//
//  Created by Lennie Stockman on 29/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import SwiftClient

class APIClient: IAPIClient {
    static let shared = APIClient()
    private var log = LogService.shared
    
    private static let BASEURL: String = "https://givtapidebug.azurewebsites.net"
    private var client = Client().baseUrl(url: BASEURL)
    
    private init() {
        
    }
    
    func get(url: String, data: [String: String], headers: [String: String] = [:], callback: @escaping (Response?) -> Void) {
        log.info(message: "GET on " + url)
        return client.get(url: url)
            .type(type: "json")
            .set(headers: headers)
            .query(query: data)
            .end(done: { (res:Response) in
                if res.basicStatus == .ok {
                    callback(res)
                } else {
                    self.log.warning(message: "GET on " + url + " returned status " + String(res.statusCode))
                    callback(nil)
                }
            }) { (err) in
                self.log.error(message: "GET on " + url + " returned an error")
                callback(nil)
        }
    }
    
    func put(url: String, data: [String: String], callback: @escaping (Bool) -> Void) {
        log.info(message: "PUT on " + url)
        client.put(url: url).send(data: data)
            .set(headers: ["Content-Type" : "application/x-www-form-urlencoded; charset=utf-8", "Authorization" : "Bearer " + UserDefaults.standard.bearerToken])
            .end(done: { (res:Response) in
                if res.basicStatus == .ok {
                    callback(true)
                } else {
                    callback(false)
                }
            }) { (err) in
                print(err)
                callback(false)
        }
    }
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) {
        log.info(message: "POST on " + url)
        client.post(url: url)
            .set(headers: ["Accept" : "application/json", "Content-Type" : "application/json", "Authorization" : "Bearer " + UserDefaults.standard.bearerToken])
            .send(data: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                print(err)
        }
    }
    
    func postForm(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) {
        log.info(message: "POST on " + url)
        client.post(url: url)
            .set(headers: ["Accept" : "application/json", "Content-Type" : "application/json", "Authorization" : "Bearer " + UserDefaults.standard.bearerToken])
            .type(type: "form")
            .send(data: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                print(err)
        }
    }
    
}
