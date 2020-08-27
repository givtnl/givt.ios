//
//  CreateRecurringDonationButton.swift
//  ios
//
//  Created by Jonas Brabant on 26/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation


protocol CreateButtonDelegate {
    func createButtonTapped() -> Void
}

@IBDesignable
class CreateRecurringDonationButton: UIView {
    
    @IBOutlet var contentView: CreateRecurringDonationButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var symbolRight: UILabel!
    
    var delegate: CreateButtonDelegate? = nil
    private var borderView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: CreateRecurringDonationButton.self)
        bundle.loadNibNamed("CreateRecurringDonationButton", owner: self, options: nil)
               
        shadowAndCorners()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func ButtonTapped(_ sender: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.createButtonTapped()
        }
    }
    
    func shadowAndCorners() {
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.backgroundColor = UIColor.clear

        borderView = UIView()
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
        borderView.frame = self.bounds
        borderView.layer.cornerRadius = 4
        borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        borderView.layer.borderWidth = 1
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
        borderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }
    
    
    
    
    
    
    
    
        
   
}
