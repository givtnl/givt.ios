//
//  RegisterCreditCardByTokenCommandHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

class RegisterCreditCardByTokenCommandHandler: RequestHandlerProtocol {
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! RegisterCreditCardByTokenCommand
        
        let body = try JSONEncoder().encode(request)
        
        try APIClient.shared.post(url: "/api/v2/users/\(request.userId)/mandates", data: body) { response in
            if let response = response, response.isSuccess {
                try? completion(ResponseModel(result: true) as! R.TResponse)
            } else {
                try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is RegisterCreditCardByTokenCommand
    }
}
