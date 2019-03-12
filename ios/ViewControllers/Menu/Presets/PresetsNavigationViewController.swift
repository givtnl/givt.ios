//
//  PresetsNavigationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 21/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import UIKit

class PresetsNavigationViewController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup nav bar
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.topItem?.titleView = UIImageView(image: #imageLiteral(resourceName: "givt20h.png"))
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PresetsSettingsViewController") as! PresetsSettingsViewController
        self.setViewControllers([vc], animated: false)
        
    }
}
