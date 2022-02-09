//
//  USSecondRegistrationViewControllerBackButtonExtension.swift
//  ios
//
//  Created by Mike Pattyn on 08/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension USSecondRegistrationViewController {
    func setupBackButton() {
        backButton.accessibilityLabel = "Back".localized
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.endEditing();
        try! Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
    }
}
