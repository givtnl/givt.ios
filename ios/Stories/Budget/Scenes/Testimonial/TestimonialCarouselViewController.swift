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
    

    override func setupViewControllers() {
        let pages: [TestimonialPageContent] = [
            TestimonialPageContent(image: UIImage(named: "testimonial1"), description: createAttributeText(bold: "BudgetTestimonialSummaryName", normal: "BudgetTestimonialSummary"))
        ]
        
        viewControllerList = [UIViewController]()
        let storyboard = UIStoryboard.init(name: "Budget", bundle: nil)
        pages.forEach { pageContent in
            let vc = storyboard.instantiateViewController(withIdentifier: "TestimonialViewController") as! TestimonialViewController
            vc.content = pageContent
            viewControllerList.append(vc)
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.currentPageIndicatorTintColor = ColorHelper.GivtPurple
        pageControl.pageIndicatorTintColor = ColorHelper.LightGrey
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
        ])
    }
    func createAttributeText(bold: String, normal: String) -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold(bold.localized + "\n", font: UIFont(name: "Avenir-Black", size: 16)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Light", size: 16)!)
    }
}
