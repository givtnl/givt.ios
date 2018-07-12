//
//  ExternalSuggestionView.swift
//  ios
//
//  Created by Lennie Stockman on 11/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ExternalSuggestionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.layer.cornerRadius = 6
        self.addSubview(label)
        self.addSubview(button)
        self.addSubview(cancelButton)
    }
    
    func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 22).isActive = true
        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        cancelButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 30).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 40).isActive = true

    }
    
    let label: UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = "Hello"
        lbl.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        lbl.font = UIFont(name: "Avenir-Light", size: 16.0)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let button: UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1)
        btn.setBackgroundColor(color: #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1), forState: UIControlState.highlighted)
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18.0)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return btn
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        btn.setImage(#imageLiteral(resourceName: "closewhite"), for: UIControlState.normal)
        return btn
    }()
}
