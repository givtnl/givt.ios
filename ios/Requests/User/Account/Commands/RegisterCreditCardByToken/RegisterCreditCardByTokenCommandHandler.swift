//
//  RegisterCreditCardByTokenCommandHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class RegisterCreditCardByTokenCommandHandler: RequestHandlerProtocol {
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! RegisterCreditCardByTokenCommand
        let body = RegisterCreditCardCommandBody(paymentMethodToken: request.PaymentMethodToken, userId: request.userId)
        
        GivtApi.UserAccounts().registerCreditCard(userId: request.userId, bearerToken: UserDefaults.standard.bearerToken!, registerCreditCardCommandBody: body) { (result, error) in
            if result != nil {
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
