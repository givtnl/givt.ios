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
    
    override func viewWillAppear(_ animated: Bool) {
        lblTitle.text = content.title
        lblText.text = content.subText
        imgIllustration.image = UIImage(named: content.image)
        colorView.backgroundColor = content.color
        
        action = content.action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {() in
            self.action(self)
        })
    }
}
