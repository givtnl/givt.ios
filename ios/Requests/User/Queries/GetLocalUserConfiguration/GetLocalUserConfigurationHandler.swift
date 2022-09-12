//
//  GetUserDetailQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal struct GetLocalUserConfigurationHandler : RequestHandlerProtocol {
    public func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! GetLocalUserConfiguration
        let paymentType = { () -> PaymentType in
            switch UserDefaults.standard.accountType {
            case .undefined :
                switch request.country {
                case "GB", "GG", "JE" : return PaymentType.BACSDirectDebit
                case "US": return PaymentType.CreditCard
                default: return PaymentType.SEPADirectDebit
                }
            case .bacs: return PaymentType.BACSDirectDebit
            default: return PaymentType.SEPADirectDebit
            }
        }()
        var userId: UUID?
        if let user = UserDefaults.standard.userExt {
            userId = UUID.init(uuidString: user.guid)
        }  
        
        try completion(LocalUserConfigurationModel(userId: userId,
                                                   paymentType: paymentType,
                                                   giftAidEnabled: UserDefaults.standard.giftAidEnabled,
                                                   mandateSigned: UserDefaults.standard.mandateSigned) as! R.TResponse)
    }
    
    public func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetLocalUserConfiguration
    }
}
