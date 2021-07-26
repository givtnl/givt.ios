//
//  BudgetYearlyOverviewViewControllerTestimonialExtension.swift
//  ios
//
//  Created by Mike Pattyn on 16/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension BudgetYearlyOverviewViewController {
    func setupTestimonial() {
        guard !UserDefaults.standard.hasSeenYearlyTestimonial else { return }
        showOverlay(type: YearlyOverviewCarouselViewController.self, fromStoryboardWithName: "Budget") { }
        UserDefaults.standard.hasSeenYearlyTestimonial = true
    }
    
}
