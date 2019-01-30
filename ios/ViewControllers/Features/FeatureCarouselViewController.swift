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
    var contentPages: [FeaturePageContent]!
    
    private var scrollView: UIScrollView? {
        get {
            for view in self.view!.subviews {
                if let v = view as? UIScrollView {
                    return v
                }
            }
            return nil
        }
    }
    
    override func setupViewControllers() {
        if let pages = contentPages {
            viewControllerList = [UIViewController]()
            let storyboard = UIStoryboard.init(name: "Features", bundle: nil)
            for page in pages{
                let vc = storyboard.instantiateViewController(withIdentifier: "feature") as! FeatureViewController
                vc.content = page
                viewControllerList.append(vc)
            }
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.831372549, green: 0.8352941176, blue: 0.8666666667, alpha: 1)
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
                ])
        } else {
            NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60)
            ])
        }
    }
}
