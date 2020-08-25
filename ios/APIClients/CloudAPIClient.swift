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

class CloudAPIClient: NSObject, URLSessionDelegate {
    static let shared = CloudAPIClient()
    private var log = LogService.shared
    
    private static let BASEURL: String = AppConstants.cloudApiUri
    
    private var client = Client().baseUrl(url: BASEURL)
    
    private override init() {
        
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
}
