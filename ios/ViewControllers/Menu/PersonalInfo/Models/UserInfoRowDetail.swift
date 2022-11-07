//
//  UserInfoRow.swift
//  ios
//
//  Created by Mike Pattyn on 11/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit

struct UserInfoRowDetail {
    var image: UIImage
    var name: String
    var type: SettingType
    var disabled: Bool = false
    var position: Int?
    
    static func address(_ address: String, _ disabled: Bool = false) -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: #imageLiteral(resourceName: "house"),
            name: address,
            type: .address,
            disabled: disabled,
            position: 3
        )
    }
    
    static func name(_ fullName: String) -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: #imageLiteral(resourceName: "personal_gray"),
            name: fullName,
            type: .name,
            disabled: true,
            position: 1
        )
    }
    
    static func phoneNumber(_ phoneNumber: String) -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: #imageLiteral(resourceName: "phone_red"),
            name: phoneNumber,
            type: .phonenumber,
            position: 4
        )
    }
    
    static func emailAddress(_ emailAddres: String) -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: #imageLiteral(resourceName: "email_sign"),
            name: emailAddres,
            type: .emailaddress,
            position: 2
        )
    }
    
    static func paymentMethod(_ details: String, paymentType: PaymentType, _ cardType: String? = nil, active: Bool = true) -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: getImageForPaymentMethod(cardType: cardType),
            name: details,
            type: mapToSettingType(paymentType: paymentType),
            disabled: !active,
            position: 5
        )
    }
    
    static func giftAid() -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: #imageLiteral(resourceName: "Giftaid_Icon-yellow"),
            name: "Gift Aid",
            type: .giftaid,
            position: 6
        )
    }
    static func shareData() -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: #imageLiteral(resourceName: "Giftaid_Icon-yellow"),
            name: "Share data",
            type: .shareData,
            position: 6
        )
    }
    static func password() -> UserInfoRowDetail {
        return UserInfoRowDetail(
            image: #imageLiteral(resourceName: "lock"),
            name: NSLocalizedString("ChangePassword", comment: ""),
            type: .changepassword,
            disabled: false,
            position: 9999
        )
    }
    
    private static func mapToSettingType(paymentType: PaymentType) -> SettingType {
        switch paymentType {
        case .BACSDirectDebit:
            return .bacs
        case .CreditCard:
            return .creditCard
        default:
            return .iban
        }
    }
    private static func getImageForPaymentMethod(cardType: String?) -> UIImage {
        guard let cardType = cardType else {
            return #imageLiteral(resourceName: "card")
        }
            return CreditCardHelper.getCreditCardCompanyLogo(CreditCardHelper.getCreditCardCompanyEnumValue(value: cardType))
        
    }
}

