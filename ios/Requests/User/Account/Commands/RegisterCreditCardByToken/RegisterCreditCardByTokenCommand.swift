//
//  RegisterCreditCardByTokenCommand.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

struct RegisterCreditCardByTokenCommand : RequestProtocol, Codable {
    typealias TResponse = ResponseModel<Bool>
    
    var userId: String
    var PaymentMethodToken: String
}
