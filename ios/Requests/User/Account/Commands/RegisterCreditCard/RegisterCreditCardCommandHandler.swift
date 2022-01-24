//
//  RegisterCreditCardCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 22/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class RegisterCreditCardCommandHandler: RequestHandlerProtocol {
    private var client = APIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        guard let userId: String = UserDefaults.standard.userExt?.guid else {
            try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
            return
        }
        
        let command = request as! RegisterCreditCardCommand

        let body = try JSONEncoder().encode(command)
        
        do {
            try client.post(url: "/api/v2/users/\(userId)/accounts", data: body) { response in
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
        return request is RegisterCreditCardCommand
    }
}
