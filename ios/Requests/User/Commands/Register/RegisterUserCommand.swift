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
    var deviceOS: Int
    var country: String
    var timeZoneId: String
    var postalCode: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
}
