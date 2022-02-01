//
//  RegisterUserCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 22/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class RegisterUserCommandHandler: RequestHandlerProtocol {
    private var client = APIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let command = request as! RegisterUserCommand
        GivtApi.User().registerUser(registerUserCommandBody: command.registerUserCommandBody) { (result, error) in
            if (result?.Id) != nil {
                try? completion(ResponseModel(result: true, error: nil) as! R.TResponse)
            } else {
                try? completion(ResponseModel(result: false, error: .registrationFailed) as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is RegisterUserCommand
    }
}
