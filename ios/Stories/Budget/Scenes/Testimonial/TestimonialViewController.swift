//
//  TestimonialViewController.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class TestimonialViewController: UIViewController {
    var content: Testimonial?
       
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: CustomButton!
    @IBOutlet weak var contentView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentView.layer.cornerRadius = 5.0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let content = content {
            imageView.image = content.image
            descriptionLabel.attributedText = content.description
            actionButton.setTitle(content.action.localized, for: .normal)
        }
        
        actionButton.titleLabel?.numberOfLines = 1
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func closeOverlay(_ sender: Any) {
        (parent as! OverlayViewController).dismissOverlay()
    }
    
    @IBAction func actionButton(_ sender: Any) {
        (parent as! OverlayViewController).dismissOverlay()
        switch content?.id {
        case 1:
            (parent as! OverlayViewController).dismissOverlay()
        case 2:
            if !AppServices.shared.isServerReachable {
                try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
            } else {
                NavigationManager.shared.executeWithLogin(context: self) {
                    let externalDonations = try! Mediater.shared.send(request: GetAllExternalDonationsQuery(fromDate: self.getStartDateOfMonth(date: Date()),tillDate: self.getEndDateOfMonth(date: Date()))).result.sorted(by: { first, second in
                        first.creationDate > second.creationDate
                    })
                    try? Mediater.shared.send(request: OpenExternalGivtsRoute(id: nil, externalDonations: externalDonations), withContext: self)
                }
            }
        case 3:
            if !AppServices.shared.isServerReachable {
                try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
            } else {
                NavigationManager.shared.executeWithLogin(context: self) {
                    try? Mediater.shared.send(request: OpenGivingGoalRoute(), withContext: self)                    
                }
            }
        case 4:
            print("So we dont instantiate the next VC twice")
        default:
            (parent as! OverlayViewController).dismissOverlay()
        }
    }
    
    func getStartDateOfMonth(date: Date) -> String {
        let calendar = Calendar.current
        let currentYear = Calendar.current.component(.year, from: date)
        let currentMonth = Calendar.current.component(.month, from: date)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = 1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func getEndDateOfMonth(date: Date) -> String {
        let calendar = Calendar.current
        let currentYear = Calendar.current.component(.year, from: date)
        let currentMonth = Calendar.current.component(.month, from: date) + 1
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = 1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
