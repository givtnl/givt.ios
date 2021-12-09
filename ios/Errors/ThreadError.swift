//
//  NotOnMainThreadError.swift
//  ios
//
//  Created by Maarten Vergouwe on 23/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

enum ThreadError : Error {
    case notOnMainThread
}
