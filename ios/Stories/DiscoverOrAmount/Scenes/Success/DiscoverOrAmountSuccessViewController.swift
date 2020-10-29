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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var goBackButton: CustomButton!
    @IBOutlet weak var shareButton: CustomButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_fourth"))
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.hidesBackButton = true
        SVProgressHUD.dismiss()
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        print("Go back")
    }
    @IBAction func shareButtonPressed(_ sender: Any) {
        print("Share")
    }
    
}
