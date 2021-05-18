//
//  CreateGivingGoalCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class CreateGivingGoalCommandHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let command = request as! CreateGivingGoalCommand
        
        let body = try JSONEncoder().encode(command.givingGoal)
        
        do {
            try client.post(url: "/giving-goal", data: body) { response in
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
        return request is CreateGivingGoalCommand
    }
}
