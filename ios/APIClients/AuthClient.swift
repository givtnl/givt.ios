//
//  AuthClient.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import SwiftClient
import TrustKit

class AuthClient: NSObject, URLSessionDelegate {
    static let shared: AuthClient = AuthClient()
    private var log: LogService = LogService.shared
    private static let BASEURL: String = AppConstants.apiUri
    private var client = Client().baseUrl(url: BASEURL)
    
    private override init() {
        
    }
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) throws {
        log.info(message: "POST on " + url)
        client.post(url: url).delegate(delegate: self)
            .set(headers: ["Accept" : "application/json", "Content-Type" : "application/json"])
            .type(type: "form")
            .send(data: data)
            .end(done: { (res:Response) in
                callback(res)
            }) { (err) in
                callback(nil)
                print(err)
                self.log.error(message: "POST on " + url + " failed somehow")
                self.handleError(err: err)
        }
    }
    
    private func handleError(err: Error) {
        let error = (err as NSError)
        let url = error.userInfo["NSErrorFailingURLStringKey"] as! String
        let description = error.userInfo["NSLocalizedDescription"] as! String
        self.log.error(message: "Following call failed: " + url + "\n" + "Description: " + description)
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
