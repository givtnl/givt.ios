//
//  DeleteGivingGoalCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class DeleteGivingGoalCommandHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        client.delete(url: "/giving-goal", data: []) { response in
            if let response = response, response.isSuccess {
                try? completion(ResponseModel(result: true) as! R.TResponse)
            } else {
                try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DeleteGivingGoalCommand
    }
}
