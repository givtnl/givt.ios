//
//  DownloadSummaryCommand.swift
//  ios
//
//  Created by Mike Pattyn on 11/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class DownloadSummaryCommand: RequestProtocol {
    typealias TResponse = ResponseModel<Bool>

    var fromDate: String
    var tillDate: String
    init(fromDate: String, tillDate: String) {
        self.fromDate = fromDate
        self.tillDate = tillDate
    }
}
