//
//  CreditCardHelper.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare
import UIKit

class CreditCardHelper {
    public static func getCreditCardCompanyEnumValue(value: String) -> CreditCardCompany {
        switch(value.lowercased()) {
        case "amex", "americanexpress":
            return .americanexpress
        case "discover":
            return .discover
        case "mastercard":
            return .mastercard
        case "visa":
            return .visa
        default:
            return .undefined
        }
    }
    public static func getCreditCardCompanyLogo(_ creditCardCompany: CreditCardCompany) -> UIImage {
        switch(creditCardCompany) {
        case .americanexpress:
            return UIImage(imageLiteralResourceName: "AmericanExpress")
        case .discover:
            return UIImage(imageLiteralResourceName: "Discover")
        case .mastercard:
            return UIImage(imageLiteralResourceName: "MasterCard")
        case .visa:
            return UIImage(imageLiteralResourceName: "Visa")
        default:
            return UIImage(imageLiteralResourceName: "card")
        }
    }
}
