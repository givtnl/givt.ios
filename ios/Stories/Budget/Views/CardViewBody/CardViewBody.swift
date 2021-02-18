//
//  CardViewBody.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit

class CardViewBody: UIView {
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
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
    }
    private func commonInit() {
        let bundle = Bundle(for: CardViewBody.self)
        bundle.loadNibNamed("CardViewBody", owner: self, options: nil)
        shadowAndCorners()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
        borderView.isUserInteractionEnabled = true
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .white
        borderView.frame = self.bounds
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
