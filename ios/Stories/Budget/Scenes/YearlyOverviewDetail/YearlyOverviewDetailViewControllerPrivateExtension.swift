//
//  YearlyOverviewDetailViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 10/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

private extension BudgetYearlyOverviewDetailViewController {
     @IBAction func backButton(_ sender: Any) {
         if !AppServices.shared.isServerReachable {
             try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
         } else {
             try? Mediater.shared.send(request: GoBackOneControllerRoute() , withContext: self)
         }
     }
     
     @IBAction func getByEmail(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            print("get by email")
        }
     }
}
