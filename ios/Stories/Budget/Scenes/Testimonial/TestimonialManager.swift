//
//  TestimonialManager.swift
//  ios
//
//  Created by Mike Pattyn on 03/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class TestimonialManager {
    static let shared: TestimonialManager = TestimonialManager()
    
    var pages: [Testimonial] = []
    
    init() {
        pages.append(Testimonial(id: 1, image: UIImage(named: "testimonial1")!, description: createAttributeText(bold: "Ah yeet", normal: "Cvaaaaaa")))
        pages.append(Testimonial(id: 2, image: UIImage(named: "testimonial1")!, description: createAttributeText(bold: "BudgetTestimonialSummaryName", normal: "BudgetTestimonialSummary")))
    }
    
    func createAttributeText(bold: String, normal: String) -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold(bold.localized + " ", font: UIFont(name: "Avenir-Black", size: 16)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Light", size: 16)!)
    }
}
