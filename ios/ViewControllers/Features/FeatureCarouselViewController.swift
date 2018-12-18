//
//  FeatureCarouselViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 17/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class FeatureCarouselViewController: BaseCarouselViewController {
    func createPage(title: String, subText: String, image: UIImage) -> FeatureViewController{
        let storyboard = UIStoryboard.init(name: "Features", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "feature") as! FeatureViewController
        vc.titleText.text = title
        vc.subText.text = subText
        vc.image.image = image
        return vc
    }
    
    override func setupViewControllers() {
        for feature in FeatureManager.shared.features {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -104)
    }
}
