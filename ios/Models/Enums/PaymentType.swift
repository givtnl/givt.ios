//
//  CollectGroupPaymentType.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

enum PaymentType : Int, Codable{
    case SEPADirectDebit = 0
    case BACSDirectDebit = 1
}
