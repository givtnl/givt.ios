//
//  BackgroundShadowView.swift
//  ios
//
//  Created by Mike Pattyn on 19/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit

class BackgroundShadowView: UIView {
    private var borderView: UIView!
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: BackgroundShadowView.self)
        bundle.loadNibNamed("BackgroundShadowView", owner: self, options: nil)
        shadowAndCorners()
        addSubview(contentView)
        contentView.frame = self.layer.frame
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    func shadowAndCorners() {
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.25).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.backgroundColor = UIColor.clear
        
        borderView = UIView()
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .clear
        borderView.frame = self.layer.frame
//        borderView.layer.cornerRadius = 4
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
