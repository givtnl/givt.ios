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
        
//        contentView.roundCorners(corners: .allCorners, radius: 5.0)
        contentView.layer.cornerRadius = 5.0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let content = content {
            imageView.image = content.image
            descriptionLabel.attributedText = content.description
        }
        
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleLabel?.numberOfLines = 1
    }
    
    @IBAction func closeOverlay(_ sender: Any) {
        (parent as! TestimonialCarouselViewController).dismissOverlay()
    }
    
    @IBAction func actionButton(_ sender: Any) {
        (parent as! TestimonialCarouselViewController).dismissOverlay()
    }
}
