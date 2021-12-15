//
//  DownloadSummaryCommandPreHandler.swift
//  ios
//
//  Created by Mike Pattyn on 15/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class DownloadSummaryCommandPreHandler : RequestPreProcessorProtocol {
    func handle<R>(request: R, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let command = request as! DownloadSummaryCommand
        
        guard command.fromDate == "" && command.tillDate == "", let year = command.year else {
            try! completion(request)
            return
        }
        
        command.fromDate = year.getUTCDateForYear(type: .start)
        command.tillDate = year.getUTCDateForYear(type: .end)
        try! completion(command as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is DownloadSummaryCommand
    }
}
