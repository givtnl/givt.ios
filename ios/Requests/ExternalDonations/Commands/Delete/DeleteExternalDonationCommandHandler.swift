//
//  DeleteExternalDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class DeleteExternalDonationCommandHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let command = request as! DeleteExternalDonationCommand
        
        let url = "/external-donations/\(command.guid)"
        
        client.delete(url: url, data: []) { response in
            if let response = response, response.isSuccess {
                try? completion(ResponseModel(result: true) as! R.TResponse)
            } else {
                try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DeleteExternalDonationCommand
    }
}
