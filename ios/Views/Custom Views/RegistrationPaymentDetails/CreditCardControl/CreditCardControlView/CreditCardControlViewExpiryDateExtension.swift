//
//  CreditCardControlViewDelegateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension CreditCardControlView {
    func setupExpiryDate() {
        creditCardExpirationDateTextField.tag = CreditCardInputFieldType.expiration.rawValue
        creditCardExpirationDateTextField.delegate = self
        createToolbar(creditCardExpirationDateTextField)
    }
}
