//
//  YearlyOverviewDetailViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 10/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD

private extension BudgetYearlyOverviewDetailViewController {
     @IBAction func backButton(_ sender: Any) {
         try? Mediater.shared.send(request: GoBackToYearlyOverviewRoute(needsReload: false) , withContext: self)
     }
     
     @IBAction func getByEmail(_ sender: Any) {
         trackEvent("CLICKED", properties: ["BUTTON_NAME": "ReceiveByEmail"])

        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            SVProgressHUD.show()
            try? Mediater.shared.sendAsync(request: DownloadSummaryCommand(fromDate: self.fromDate, tillDate: self.tillDate), completion: { response in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.finishedDownloadAlert(success: response.result)
                }
            })
        }
     }
    
    func finishedDownloadAlert(success: Bool) {
        let alert = UIAlertController(
            title: success ? "Success".localized : "RequestFailed".localized,
            message: success ? "GiftsOverviewSent".localized : "CouldNotSendTaxOverview".localized,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))
        self.present(alert, animated: true, completion:  {})
    }
}
