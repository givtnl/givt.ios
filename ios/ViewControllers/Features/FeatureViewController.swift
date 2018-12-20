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
    var action: (UIViewController?)->Void = {(_) in}

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var imgIllustration: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = content.title
        lblText.text = content.subText
        imgIllustration.image = UIImage(named: content.image)
        colorView.backgroundColor = content.color
        
        action = content.action
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {() in
            self.action(self)
        })
        self.view!.isUserInteractionEnabled = true
    
    }
}
