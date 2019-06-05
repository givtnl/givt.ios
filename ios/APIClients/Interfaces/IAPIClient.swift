//
//  IAPIClient.swift
//  ios
//
//  Created by Lennie Stockman on 29/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import SwiftClient

protocol IAPIClient {
    func get(url: String, data: [String: String], headers: [String: String], timeout: Double, callback: @escaping (Response?) -> Void) -> Void
    
    func put(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) throws -> Void
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) throws -> Void
    
    func post(url: String, data: Data, callback: @escaping (Response?) -> Void) throws -> Void
}

extension IAPIClient { //extension for the default timeout
    func get(url: String, data: [String: String], headers: [String: String], timeout: Double = 60, callback: @escaping (Response?) -> Void) -> Void {
        return get(url: url, data: data, headers: headers, timeout: timeout, callback: callback)
    }
}
