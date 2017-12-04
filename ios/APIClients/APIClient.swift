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
        var headers = headers
        if let bearerToken = UserDefaults.standard.bearerToken {
                headers["Authorization"] = "Bearer " + bearerToken
        }
        log.info(message: "GET on " + url)
        client.get(url: url)
            .type(type: "json")
            .set(headers: headers)
            .query(query: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                self.log.error(message: "GET on " + url + " failed somehow")
        }
    }
    
    func put(url: String, data: [String: String], callback: @escaping (Response?) -> Void) throws {
        log.info(message: "PUT on " + url)
        client.put(url: url).send(data: data)
            .type(type: "json")
            .set(headers: ["Authorization" : "Bearer " + UserDefaults.standard.bearerToken!])
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                print(err)
                callback(nil)
                self.log.error(message: "PUT on " + url + " failed somehow")
        }
    }
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) throws {
        log.info(message: "POST on " + url)
        var headers: [String: String] = [:]
        if let bearerToken = UserDefaults.standard.bearerToken {
            headers["Authorization"] = "Bearer " + bearerToken
        }
        client.post(url: url)
            .type(type: "json")
            .set(headers: headers)
            .send(data: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                print(err)
                self.log.error(message: "POST on " + url + " failed somehow")
        }
    }
}
