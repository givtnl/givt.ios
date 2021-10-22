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
