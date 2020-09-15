//
//  ResponseExtension.swift
//  ios
//
//  Created by Mike Pattyn on 03/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SwiftClient

extension Response {
    var isSuccess: Bool {
       return statusCode >= 200 && statusCode < 300
    }
}
