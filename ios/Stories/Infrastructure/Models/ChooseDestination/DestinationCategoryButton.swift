//
//  DestinationCategoryButton.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class DestinationCategoryButton : UIButton {
    private var color: UIColor!
    private var imageWhenActive: UIImage!
    private var imageWhenInactive: UIImage!
    public var labelText: String!
    public var active: Bool!
    
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    init (color: UIColor, imageWhenInactive: UIImage, imageWhenActive: UIImage, labelText: String, tag: Int = 0) {
        super.init(frame: .zero)
        self.color = color
        self.imageWhenActive = imageWhenActive
        self.imageWhenInactive = imageWhenInactive
        self.labelText = labelText
        self.tag = tag
        self.accessibilityLabel = labelText
        self.active = true //needed to let setInactive work :)
        setInactive()
    }
            
    public func setInactive() {
        if !active {
            return
        }

        // first remove all views
        for view in subviews {
            view.removeFromSuperview()
        }
        if let heightConstraint = heightConstraint, let widthConstraint = widthConstraint {
            removeConstraints([heightConstraint, widthConstraint])
        }
        
        // some button constraints
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 60)
        heightConstraint!.isActive = true
        widthConstraint = widthAnchor.constraint(equalToConstant: 60)
        widthConstraint!.isActive = true
        backgroundColor = color
        layer.cornerRadius = 3
        // show the inactive image
        let image = UIImageView(image: imageWhenInactive)
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.contentMode = .scaleAspectFit
        image.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        // set the button label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont(name: "Avenir Heavy", size: 11)
        label.text = labelText
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -4).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        //create shadow
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        self.active = false
    }
    
    public func setActive() {
        if active {
            return
        }
        
        // first remove all views
        for view in subviews {
            view.removeFromSuperview()
        }
        if let heightConstraint = heightConstraint, let widthConstraint = widthConstraint {
            removeConstraints([heightConstraint, widthConstraint])
        }

        // some button constraints
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        heightConstraint = heightAnchor.constraint(equalToConstant: 75)
        heightConstraint!.isActive = true
        widthConstraint = widthAnchor.constraint(equalToConstant: 75)
        widthConstraint!.isActive = true
        
        //add a border
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
        borderView.frame = bounds
        borderView.layer.cornerRadius = 3
        borderView.layer.borderColor = color.cgColor
        borderView.layer.borderWidth = 1
        borderView.layer.masksToBounds = true
        addSubview(borderView)
        borderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        //and a bar
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        bar.backgroundColor = color
        borderView.addSubview(bar)
        bar.bottomAnchor.constraint(equalTo: borderView.bottomAnchor).isActive = true
        bar.leadingAnchor.constraint(equalTo: borderView.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: borderView.trailingAnchor).isActive = true
        
        //set the label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir Heavy", size: 12)
        label.text = labelText
        label.textColor = color
        borderView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -4).isActive = true
        
        //show the active image
        let image = UIImageView(image: imageWhenActive)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        borderView.addSubview(image)
        image.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 4).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -4).isActive = true
        
        self.active = true
    }
    
    public func addTapGesture(_ target: Any, action: Selector) {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(target, action: action)
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
