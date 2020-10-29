//
//  DiscoverOrAmountViewController.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class DiscoverOrAmountSuccessViewController: UIViewController {
    private var mediater: MediaterWithContextProtocol = Mediater.shared

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var goBackButton: CustomButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_fourth"))
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.hidesBackButton = true
        SVProgressHUD.dismiss()
        
        setupLabels()
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        try? mediater.send(request: BackToMainViewRoute(), withContext: self)
    }
    
    func setupLabels() {
        subtitleLabel.text = "OfflineGegevenGivtMessage".localized
        titleLabel.text = "YesSuccess".localized
        goBackButton.setTitle("Ready".localized, for: .normal)
    }
}
