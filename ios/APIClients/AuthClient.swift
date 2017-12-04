//
//  AuthClient.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import SwiftClient

class AuthClient {
    static let shared: AuthClient = AuthClient()
    private var log: LogService = LogService.shared
    private static let BASEURL: String = "https://givtapidebug.azurewebsites.net"
    private var client = Client().baseUrl(url: BASEURL)
    
    private init() {
        
    }
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) throws {
        log.info(message: "POST on " + url)
        client.post(url: url)
            .set(headers: ["Accept" : "application/json", "Content-Type" : "application/json", "Authorization" : "Bearer " + UserDefaults.standard.bearerToken!])
            .type(type: "form")
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
