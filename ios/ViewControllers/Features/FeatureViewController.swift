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
    
    var callingCarousselController: FeatureCarouselViewController? = nil

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
        if content.action != nil {
            action = content.action
            btnAction.isHidden = false
            btnAction.addTarget(self, action: #selector(FeatureViewController.buttonClicked(_:)), for: .touchUpInside)
        } else {
            btnAction.isHidden = true
        }
        self.view!.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if content.action != nil {
            callingCarousselController?.hideSkipButton()
        } else {
            callingCarousselController?.showSkipButton()
        }
    }
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        if let actie = self.action {
            actie(self)
        }
    }
}
