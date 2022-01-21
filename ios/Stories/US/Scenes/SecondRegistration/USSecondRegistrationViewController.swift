//
//  USSecondRegistrationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel
import AppCenterAnalytics
import SVProgressHUD

class USSecondRegistrationViewController: UIViewController {
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet var theScrollView: UIScrollView!
    
    @IBOutlet weak var firstNameTextField: CustomUITextField!
    @IBOutlet weak var lastNameTextField: CustomUITextField!
    @IBOutlet weak var postalCodeTextField: CustomUITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var viewModel = USSecondRegistrationViewModel()

    // user details from previous screen
    var registerUserCommand: RegisterUserCommand!
    var registerCreditCardByTokenCommand: RegisterCreditCardByTokenCommand!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var faqButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(imageLiteralResourceName: "givt20h.png"))
        
        SVProgressHUD.dismiss { [self] in
            initViewModel()
            setupUI()
            
            Analytics.trackEvent("US User started second registration")
            Mixpanel.mainInstance().track(event: "US User started second registration")
        }
        
        
        SVProgressHUD.dismiss()
    }
    
}
