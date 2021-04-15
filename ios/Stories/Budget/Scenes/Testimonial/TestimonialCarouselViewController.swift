//
//  TestimonialViewController.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

struct TestimonialPageContent {
    var id: Int
    var image: UIImage
    var description: NSMutableAttributedString
}

class TestimonialPageContentManager {
    static let shared: TestimonialPageContentManager = TestimonialPageContentManager()
    
    var pages: [TestimonialPageContent] = []
    
    init() {
        pages.append(TestimonialPageContent(id: 1, image: UIImage(named: "testimonial1")!, description: createAttributeText(bold: "BudgetTestimonialSummaryName", normal: "BudgetTestimonialSummary")))
    }
    
    func createAttributeText(bold: String, normal: String) -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold(bold.localized + " ", font: UIFont(name: "Avenir-Black", size: 16)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Light", size: 16)!)
    }
}

class TestimonialCarouselViewController: BaseCarouselViewController, OverlayViewController {
    var overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 300.0)
    var pages: [TestimonialPageContent] = [TestimonialPageContent]()

    override func setupViewControllers() {
        let lastShownTestimonial = UserDefaults.standard.lastShownTestimonial
        
        if lastShownTestimonial == nil {
            pages.append(TestimonialPageContentManager.shared.pages.first { $0.id == 1}!)
            UserDefaults.standard.lastShownTestimonial = 1
        }
        
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
        if pages.count > 1 {
            pageControl.currentPageIndicatorTintColor = ColorHelper.GivtPurple
            pageControl.pageIndicatorTintColor = ColorHelper.LightGrey
            NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
            ])
        }
    }
}
