//
//  ResponseError.swift
//  ios
//
//  Created by Maarten Vergouwe on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public enum ResponseError {
    case unknown
    case unauthorized
    case duplicate
    case parseError
    case registrationFailed
    case notFound
}
