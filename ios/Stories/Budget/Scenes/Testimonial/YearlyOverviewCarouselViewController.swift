//
//  YearlyOverviewCarouselViewController.swift
//  ios
//
//  Created by Mike Pattyn on 16/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import Mixpanel
import UIKit

class YearlyOverviewCarouselViewController: BaseCarouselViewController, OverlayViewController {
    var completion: (() -> Void)?
    var overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 300.0)
    var pages: [Testimonial] = [Testimonial]()
    
    override func setupViewControllers() {
        pages = TestimonialManager.shared.yearlyOverviewPages

        viewControllerList = [UIViewController]()
        
        let storyboard = UIStoryboard.init(name: "Budget", bundle: nil)
        
        pages.forEach { pageContent in
            let vc = storyboard.instantiateViewController(withIdentifier: "TestimonialViewController") as! TestimonialViewController
            vc.content = pageContent
            viewControllerList.append(vc)
        }
        
        viewControllerList = (viewControllerList as! [TestimonialViewController]).sorted(by: { first, second in
            return first.content!.id < second.content!.id
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Mixpanel.mainInstance().track(event: "LOADED", properties: ["TESTIMONIAL_NAME": "YearlyOverview"])

        pageControl.currentPageIndicatorTintColor = ColorHelper.GivtPurple
        pageControl.pageIndicatorTintColor = ColorHelper.LightGrey
        pageControl.hidesForSinglePage = true
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
        ])
    }
}
