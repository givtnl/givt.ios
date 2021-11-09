//
//  RegisterUserCommand.swift
//  ios
//
//  Created by Mike Pattyn on 22/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

internal struct RegisterUserCommand : RequestProtocol, Codable {
    typealias TResponse = ResponseModel<Bool>
    
    var userId: String
    var email: String
    var phoneNumber: String
    var password: String
    var appLanguage: String
    var deviceOS: String
    var country: String
    
    internal init(userId: String,
                  email: String,
                  phoneNumber: String,
                  password: String,
                  appLanguage: String,
                  deviceOS: String,
                  country: String) {
        self.userId = userId
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.appLanguage = appLanguage
        self.deviceOS = deviceOS
        self.country = country
    }
}
