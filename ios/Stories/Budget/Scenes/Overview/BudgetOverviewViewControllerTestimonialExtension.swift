//
//  BudgetOverviewTestimonialExtension.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension BudgetOverviewViewController {
    func loadTestimonial() {
        if TestimonialPageContentManager.shared.pages.last?.id != UserDefaults.standard.lastShownTestimonial {
            self.showOverlay(type: TestimonialCarouselViewController.self, fromStoryboardWithName: "Budget")
        }
    }
}
