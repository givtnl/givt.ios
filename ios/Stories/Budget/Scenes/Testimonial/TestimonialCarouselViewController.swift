//
//  TestimonialViewController.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class TestimonialCarouselViewController: BaseCarouselViewController, OverlayViewController {
    var overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 300.0)
    var pages: [Testimonial] = [Testimonial]()
    
    override func setupViewControllers() {
        pages = TestimonialManager.shared.pages
        
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
        
        pageControl.currentPageIndicatorTintColor = ColorHelper.GivtPurple
        pageControl.pageIndicatorTintColor = ColorHelper.LightGrey
        pageControl.hidesForSinglePage = true
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
        ])
        
        let lastSeenTestimonial = UserDefaults.standard.lastShownTestimonial
        
        if lastSeenTestimonial == nil {
            UserDefaults.standard.lastShownTestimonial = TestimonialSetting(id: 1, date: Date().formattedYearAndMonth)
            pageControl.currentPage = 0
        } else {
            let vcs = (viewControllerList as! [TestimonialViewController]).sorted(by: { first, second in
                return first.content!.id < second.content!.id
            })
            
            if let nextVc: TestimonialViewController = vcs.first(where: { $0.content!.id > UserDefaults.standard.lastShownTestimonial!.id }) {
                UserDefaults.standard.lastShownTestimonial = TestimonialSetting(id: nextVc.content!.id, date: Date().formattedYearAndMonth)
                loadPageAtIndex(self.viewControllerList.firstIndex(of: nextVc)!)
            }
        }
    }
}
