//
//  CreditCardControlViewCVVExtension.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension CreditCardControlView {
    func setupCVV() {
        creditCardCVVTextField.keyboardType = .numberPad
        creditCardCVVTextField.tag = CreditCardInputFieldType.cvv.rawValue
        creditCardCVVTextField.delegate = self
        createToolbar(creditCardCVVTextField)
    }
}
