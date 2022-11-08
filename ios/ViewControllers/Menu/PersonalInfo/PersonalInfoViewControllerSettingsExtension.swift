//
//  PersonalInfoViewControllerSettingsExtension.swift
//  ios
//
//  Created by Mike Pattyn on 10/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit

extension PersonalInfoViewController {
    
    func generateUserInfoRows(completion: @escaping ([UserInfoRowDetail]) -> Void) {
        var retVal = [UserInfoRowDetail]()
        do {
            retVal = [
                try UserInfoRowDetail.address(
                    self.uExt!.getFullAddress(),
                    UserDefaults.standard.paymentType == .CreditCard
                ),
                try UserInfoRowDetail.name(self.uExt!.getFullName()),
                UserInfoRowDetail.phoneNumber(self.uExt!.PhoneNumber),
                UserInfoRowDetail.emailAddress(self.uExt!.Email),
                UserInfoRowDetail.password()
            ]
            
            switch try! self.uExt!.getPaymentType() {
            case .SEPADirectDebit:
                retVal.insert(try UserInfoRowDetail.paymentMethod(self.uExt!.getPrettyIban(), paymentType: self.uExt!.getPaymentType()), at: retVal.count - 1)
            case .BACSDirectDebit:
                retVal.insert(contentsOf: [
                    try UserInfoRowDetail.paymentMethod(self.uExt!.getPrettySortCodeAndAccountNumber(), paymentType: self.uExt!.getPaymentType()), UserInfoRowDetail.giftAid()
                ], at: retVal.count - 1)
            case .CreditCard:
                if let cardNumber = self.uExt?.CreditCardNumber, let cardType = self.uExt?.CreditCardType, let isActive = self.uExt?.AccountActive {
                    retVal.insert(
                        UserInfoRowDetail.paymentMethod(cardNumber, paymentType: try! self.uExt!.getPaymentType(), cardType, active: isActive), at: retVal.count - 1)
                    retVal[retVal.count - 2].image = retVal[retVal.count - 2].image.resized(to: retVal.first!.image.size)!
                }
                retVal.insert(UserInfoRowDetail.shareData(), at: retVal.count - 1)
            default:
                break
            }
        } catch {
            print(error)
        }
        completion(retVal)
    }
}

enum SettingType: CaseIterable {
    case name
    case emailaddress
    case address
    case countrycode
    case phonenumber
    case iban
    case changepassword
    case bacs
    case giftaid
    case creditCard
    case removePaymentMethod
    case shareData
}


