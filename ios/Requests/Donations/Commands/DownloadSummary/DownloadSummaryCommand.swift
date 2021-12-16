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
    
    var year: Int?
    
    init(fromDate: String, tillDate: String, year: Int? = nil) {
        self.fromDate = fromDate
        self.tillDate = tillDate
        self.year = year
    }
}
