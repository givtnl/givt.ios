//
//  BudgetViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation


//MARK: Private extension - used to store private methods and actions
private extension BudgetOverviewViewController {
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: BackToMainRoute(), withContext: self)
    }
    @IBAction func giveNowButton(_ sender: Any) {
        try? Mediater.shared.send(request: OpenGiveNowRoute(), withContext: self)
    }
    @IBAction func buttonSeeMore(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            NavigationManager.shared.executeWithLogin(context: self, completion: {
                let collections: [AnyObject] = [self.collectGroupsForCurrentMonth as Any, self.notGivtModelsForCurrentMonth as Any, self.fromMonth as Any] as [AnyObject]
                self.showOverlay(type: BudgetListViewController.self, fromStoryboardWithName: "Budget", collections: collections)
            })
        }
    }
    @IBAction func buttonPlus(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            try? Mediater.shared.send(request: OpenExternalGivtsRoute(externalDonations: self.notGivtModelsForCurrentMonth), withContext: self)
        }
    }
    @IBAction func goBackOneMonth(_ sender: Any) {
        fromMonth = getPreviousMonth(from: fromMonth)
        
        updateMonthCard()
    }
    @IBAction func goForwardOneMonth(_ sender: Any) {
        fromMonth = getNextMonth(from: fromMonth)
        
        updateMonthCard()
    }
}
