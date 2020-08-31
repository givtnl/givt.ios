//
//  CreateRecurringDonationButton.swift
//  ios
//
//  Created by Jonas Brabant on 26/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class CreateRecurringDonationButton: UIControl {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var symbolRight: UILabel!
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.backgroundColor = #colorLiteral(red: 0.2529559135, green: 0.789002955, blue: 0.554667592, alpha: 1)
        super.touchesEnded(touches, with: event)
    }
        
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.backgroundColor = #colorLiteral(red: 0.2529559135, green: 0.789002955, blue: 0.554667592, alpha: 1)
        super.touchesCancelled(touches, with: event)
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
        contentView.layer.cornerRadius = 8
    }
}
