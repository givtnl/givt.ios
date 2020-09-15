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
        let paymentType = UserDefaults.standard.accountType == .undefined
            ?
            (NSLocale.current.regionCode == "GB" || NSLocale.current.regionCode == "GG" || NSLocale.current.regionCode == "JE" ) ? PaymentType.BACSDirectDebit : PaymentType.SEPADirectDebit
            :
            UserDefaults.standard.accountType == .bacs ? PaymentType.BACSDirectDebit : PaymentType.SEPADirectDebit
        
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
