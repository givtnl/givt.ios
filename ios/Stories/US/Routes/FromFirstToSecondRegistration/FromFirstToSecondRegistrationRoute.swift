//
//  FromFirstToSecondRegistrationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class FromFirstToSecondRegistrationRoute: NoResponseRequest {
    var registerUserCommand: RegisterUserCommandBody
    var registerCreditCardByTokenCommand: RegisterCreditCardByTokenCommand
    init(registerUserCommand: RegisterUserCommandBody, registerCreditCardByTokenCommand: RegisterCreditCardByTokenCommand) {
        self.registerUserCommand = registerUserCommand
        self.registerCreditCardByTokenCommand = registerCreditCardByTokenCommand
    }
}
