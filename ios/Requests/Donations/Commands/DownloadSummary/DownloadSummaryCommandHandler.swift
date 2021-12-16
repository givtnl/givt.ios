//
//  DownloadSummaryCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 11/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class DownloadSummaryCommandHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let command = request as! DownloadSummaryCommand
   
        let body = ["fromDate":command.fromDate, "tillDate":command.tillDate]
        
        do {
            try client.post(url: "/donations/download", data: body) { response in
                if let response = response, response.isSuccess {
                    try? completion(ResponseModel(result: true) as! R.TResponse)
                } else {
                    try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
                }
            }
        } catch {
            try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is DownloadSummaryCommand
    }
}
