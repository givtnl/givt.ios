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
    func get(url: String, data: [String: String], headers: [String: String], callback: @escaping (Response?) -> Void) -> Void
    
    func put(url: String, data: [String: String], callback: @escaping (Bool) -> Void) -> Void
    
    func post(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) -> Void
    
    func postForm(url: String, data: [String: Any], callback: @escaping (Response?) -> Void) -> Void
}
