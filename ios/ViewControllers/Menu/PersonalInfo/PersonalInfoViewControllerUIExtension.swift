//
//  PersonalInfoViewControllerUIExtension.swift
//  ios
//
//  Created by Mike Pattyn on 10/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension PersonalInfoViewController {
    func loadSettings(_ completionHandler: @escaping ([UserInfoRowDetail]) -> Void) {
        if !AppServices.shared.isServerReachable {
            return
        }
        
        self.settings = [UserInfoRowDetail]()
        
        SVProgressHUD.show()
        
        LoginManager.shared.getUserExt { response in
            guard let userExtension = response else {
                return self.showAlertWithConfirmation(title: "RequestFailed".localized, message: "CantFetchPersonalInformation".localized) { action in
                    DispatchQueue.main.async {
                        self.backPressed(self)
                        completionHandler([])
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.uExt = userExtension
                
                try? Mediater.shared.sendAsync(request: GetAccountsQuery()) { accountDetails in
                    if UserDefaults.standard.paymentType == .CreditCard {
                        if let account = accountDetails.result?.first {
                            if let creditCardDetails = account.CreditCardDetails {
                                self.uExt?.CreditCardNumber = self.formatCreditCard(creditCardDetails.CardNumber, creditCardDetails.CardType)
                                self.uExt?.CreditCardType = creditCardDetails.CardType
                                self.uExt?.AccountActive = account.Active
                            }
                        }
                    }
                    
                    self.generateUserInfoRows { settings in
                        completionHandler(settings.sorted(by: { first, second in
                            first.position! < second.position!
                        }))
                    }
                }
            }
        }
    }
    
    func formatCreditCard(_ cardNumber: String, _ cardType: String) -> String {
        var length: Int = 19
        switch cardType {
            case "Visa", "Mastercard", "Discover": length = 16
            case "Amex": length = 15
            default: length = 19
        }
        return "\(String(repeating: "*", count: length - 4))\(cardNumber[cardNumber.index(cardNumber.endIndex, offsetBy: -4)...])".chunked(by: 4)
    }
    
    func setupUI() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        title = NSLocalizedString("TitlePersonalInfo", comment: "")
        settings = [UserInfoRowDetail]()
        settingsTableView.tableFooterView = UIView()
        self.navigationController?.removeLogo()
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        lbl.font = UIFont(name: "Avenir-Light", size: 16.0)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = NSLocalizedString("PersonalPageHeader", comment: "") + "\n\n" + NSLocalizedString("PersonalPageSubHeader", comment: "")
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(lbl)
        lbl.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        lbl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
        lbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        lbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
        settingsTableView.tableHeaderView = containerView
        
        containerView.widthAnchor.constraint(equalTo: self.settingsTableView.widthAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.settingsTableView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.settingsTableView.topAnchor, constant: 10).isActive = true
        
        self.settingsTableView.layoutIfNeeded()
        self.settingsTableView.tableHeaderView = self.settingsTableView.tableHeaderView
    }
}
