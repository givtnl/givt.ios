//
//  CollectGroupPaymentType.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

enum PaymentType : Int, Codable {
    case Undefined = -1
    case SEPADirectDebit = 0
    case BACSDirectDebit = 1
    case CreditCard = 2
}

extension PaymentType {
    var isCreditCard: Bool {
        return self == PaymentType.CreditCard
    }
    var isBacs: Bool {
        return self == PaymentType.BACSDirectDebit
    }
    var isSepa: Bool {
        return self == PaymentType.SEPADirectDebit
    }
    
    static func fromAccountType(_ accountType: AccountType) -> PaymentType {
        switch(accountType) {
        case .sepa:
            return PaymentType.SEPADirectDebit
        case .bacs:
            return PaymentType.BACSDirectDebit
        default:
            return PaymentType.Undefined
        }
    }
}
