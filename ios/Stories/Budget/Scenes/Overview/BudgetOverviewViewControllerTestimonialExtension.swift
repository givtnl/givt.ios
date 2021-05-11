//
//  BudgetOverviewTestimonialExtension.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension BudgetOverviewViewController {
    func setupTestimonial() {
        if let lastSeenTestimonial = UserDefaults.standard.lastShownTestimonial {
            let lastSeenDate: String = lastSeenTestimonial.date
            
            guard lastSeenDate.contains("-") else {
                return
            }
            
            let lastSeenYear = Int(lastSeenDate.split(separator: "-")[0])!
            let lastSeenMonth = Int(lastSeenDate.split(separator: "-")[1])!
            
            let currentDate = Date()
            let currentYear = currentDate.getYear()
            let currentMonth = currentDate.getMonth()
            
            if (lastSeenYear == currentYear && lastSeenMonth < currentMonth || lastSeenYear < currentYear) {
                self.showOverlay(type: TestimonialCarouselViewController.self, fromStoryboardWithName: "Budget")
            }
        } else {
            self.showOverlay(type: TestimonialCarouselViewController.self, fromStoryboardWithName: "Budget")
        }
    }
}
