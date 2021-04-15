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
    var content: TestimonialPageContent?
    
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
            if content.image != nil {
                imageView.image = content.image
            }
            descriptionLabel.attributedText = content.description
        }
    }
    
    @IBAction func closeOverlay(_ sender: Any) {
        (parent as! TestimonialCarouselViewController).dismissOverlay()
    }
    
    @IBAction func actionButton(_ sender: Any) {
        (parent as! TestimonialCarouselViewController).dismissOverlay()
    }
}
