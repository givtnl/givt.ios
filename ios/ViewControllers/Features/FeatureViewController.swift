//
//  FeatureViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 17/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class FeatureViewController: UIViewController {
    var content: FeaturePageContent!
    var action: ((UIViewController?)->())? = nil
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var imgIllustration: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet var btnAction: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = content.title
        lblText.text = content.subText
        imgIllustration.image = UIImage(named: content.image)
        colorView.backgroundColor = content.color
        btnAction.isHidden = true;
        if content.action != nil && content.actionText != nil {
            action = content.action
            btnAction.isHidden = false
            
            if let text = content.actionText {
                btnAction.setTitle(text(self), for: .normal)
            }
            btnAction.addTarget(self, action: #selector(FeatureViewController.buttonClicked(_:)), for: .touchUpInside)
        } else {
            btnAction.isHidden = true
        }
        self.view!.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let featuresFirstController = self.parent!.parent as? FeaturesFirstViewController {
            if content.action != nil {
                featuresFirstController.changeSkipVisibility(visible: false)
            } else {
                featuresFirstController.changeSkipVisibility(visible: true)
            }
        }
    }
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        if let actie = self.action {
            actie(self)
            
        }
    }
}
