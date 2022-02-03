//
//  RegisterUserCommand.swift
//  ios
//
//  Created by Mike Pattyn on 22/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

internal struct RegisterUserCommand : RequestProtocol {
    typealias TResponse = ResponseModel<Bool>
    
    var registerUserCommandBody: RegisterUserCommandBody
    init(registerUserCommandBody: RegisterUserCommandBody) {
        self.registerUserCommandBody = registerUserCommandBody
    }
}
