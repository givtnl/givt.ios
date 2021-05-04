//
//  GetGivingGoalQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetGivingGoalQueryHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        client.get(url: "/giving-goal", data: [:]) { (response) in
            var responseModel: GivingGoal? = nil
            
            if let response = response, response.isSuccess {
                if let body = response.text {
                    do {
                        let decoder = JSONDecoder()
                        responseModel = try decoder.decode(GivingGoal.self, from: Data(body.utf8))
                    } catch {
                        print("\(error)")
                    }
                    try? completion(responseModel as! R.TResponse)
                }
            } else {
                try? completion(responseModel as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetGivingGoalQuery
    }
}
