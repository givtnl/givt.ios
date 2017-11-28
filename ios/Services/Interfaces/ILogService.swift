//
//  ILogService.swift
//  ios
//
//  Created by Lennie Stockman on 28/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation

protocol ILogService {
    func debug(message: String, method: String, file: String, linenr: Int) -> Void
    func info(message: String, method: String, file: String, linenr: Int) -> Void
    func warning(message: String, method: String, file: String, linenr: Int) -> Void
    func error(message: String, method: String, file: String, linenr: Int) -> Void
}
