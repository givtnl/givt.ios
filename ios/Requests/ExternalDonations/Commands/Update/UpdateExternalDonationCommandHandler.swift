//
//  UpdateExternalDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class UpdateExternalDonationCommandHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! UpdateExternalDonationCommand
        
        let body = try JSONEncoder().encode(UpdateExternalDonationBody(
            cronExpression: request.cronExpression,
            description: request.description,
            amount: request.amount,
            taxDeductable: request.taxDeductable
        ))
        
        let url = "/external-donations/\(request.id)"
        client.patch(url: url, data: body) { response in
            if let response = response, response.isSuccess {
                try? completion(ResponseModel(result: true) as! R.TResponse)
            } else {
                try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is UpdateExternalDonationCommand
    }
}
