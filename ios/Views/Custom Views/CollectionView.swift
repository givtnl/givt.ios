//
//  CollecteView.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import UIKit

@IBDesignable
class CollectionView: UIView {
    private var borderView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var collectLabel: UILabel!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencySign: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CollectionView", owner: self, options: nil)
        shadowAndCorners()
        styleDeleteButton()
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
    
    func styleDeleteButton() {
        deleteBtn.isHidden = true
        deleteBtn.setImage(#imageLiteral(resourceName: "decrease"), for: UIControlState.normal)
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        deleteBtn.contentMode = UIViewContentMode.scaleAspectFit
        deleteBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.alpha = 0.5
    }
}
