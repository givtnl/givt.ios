//
//  FromFirstToSecondRegistrationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation


class FromFirstToSecondRegistrationRoute: NoResponseRequest {
    var registerUserCommand: RegisterUserCommand!
    var registerCreditCardCommand: RegisterCreditCardCommand!
    init(registerUserCommand: RegisterUserCommand, registerCreditCardCommand: RegisterCreditCardCommand!) {
        self.registerUserCommand = registerUserCommand
        self.registerCreditCardCommand = registerCreditCardCommand
    }
}
