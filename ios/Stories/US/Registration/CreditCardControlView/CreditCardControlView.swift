//
//  CreditCardControlView.swift
//  ios
//
//  Created by Mike Pattyn on 09/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import GivtCodeShare
import Charts

class CreditCardControlView: UIView {
    @IBOutlet var contentView: UIView!
    
    // MARK: Card Number
    @IBOutlet weak var creditCardNumberView: UIView!
    @IBOutlet weak var creditCardNumberTextField: CustomUITextField!
    @IBOutlet weak var creditCardCompanyImageView: UIImageView!
    
    // MARK: Expiration Date
    @IBOutlet weak var creditCardExpirationDateTextField: CustomUITextField!
    
    // MARK: CVV
    @IBOutlet weak var creditCardCVVTextField: CustomUITextField!
    
    var viewModel: CreditCardControlViewModel = CreditCardControlViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: CreditCardControlView.self)
        bundle.loadNibNamed("CreditCardControlView", owner: self, options: nil)
        addSubview(contentView)
        
        initViewModel()
        setupUI()
    }
    
    func setupUI() {
        setupCreditCardNumber()
        setupExpiryDate()
        setupCVV()
    }
    
    func initViewModel() {
        viewModel.updateView = { [weak self] () in
            DispatchQueue.main.async {
                self?.viewModel.setExpiryTextField?()
                self?.viewModel.setCardNumberTextField?()
                self?.viewModel.setCVVTextField?()
            }
        }
        
        viewModel.setCardNumberTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.creditCardNumberTextField.text = self?.viewModel.creditCardValidator.creditCard.formatted
            }
        }
        viewModel.setCreditCardCompanyLogo = { [weak self ]() in
            DispatchQueue.main.async {
                let creditCardCompany = self?.viewModel.creditCardValidator.creditCard.company
                self?.creditCardCompanyImageView.image = getCreditCardCompanyLogo(creditCardCompany ?? CreditCardCompany.undefined)
            }
        }
        viewModel.setExpiryTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.creditCardExpirationDateTextField.text = self?.viewModel.creditCardValidator.creditCard.expiryDate.formatted
            }
        }
        viewModel.setCVVTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.creditCardCVVTextField.text = self?.viewModel.creditCardValidator.creditCard.securityCode
            }
        }
        viewModel.validateCardNumber =  { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.creditCardValidator.cardNumberIsValid() {
                    self?.creditCardNumberView.setBorders(isValid)
                }
            }
        }
        viewModel.validateExpiryDate = { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.creditCardValidator.expiryDateIsValid() {
                    self?.creditCardExpirationDateTextField.setBorders(isValid)
                }
            }
        }
        viewModel.validateSecurityCode = { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.creditCardValidator.securityCodeIsValid() {
                    self?.creditCardCVVTextField.setBorders(isValid)
                }
            }
        }
    }
}

