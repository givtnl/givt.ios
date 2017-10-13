//
//  Balloon.swift
//  ios
//
//  Created by Lennie Stockman on 12/10/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

class Balloon: UIView {
    var topConstraint: NSLayoutConstraint!
    var leftConstraint: NSLayoutConstraint!
    var pointer: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }
    
    convenience init(text: String){
        self.init(frame: CGRect.zero) // calls the initializer above
        self.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5.0
        addLabel(text: text)
        addPointer()
        self.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addLabel(text: String) {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Roman", size: 15.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.numberOfLines = 0
        label.textAlignment = .center
        self.addSubview(label)
        let margin = CGFloat(7)
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: margin).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -margin).isActive = true
    }
    
    private func addPointer() {
        pointer = UIView()
        pointer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        pointer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pointer)

        pointer.centerYAnchor.constraint(equalTo: self.topAnchor).isActive = true
        pointer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pointer.widthAnchor.constraint(equalToConstant: 20).isActive = true
        pointer.transform = pointer.transform.rotated(by: CGFloat(Double.pi/4))
    }
    
    func pinTop(view toView: UIView, _ constant: CGFloat = 0) {
        topConstraint = self.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: constant)
        topConstraint.isActive = true
    }
    
    func pinLeft(view toView: UIView, _ constant: CGFloat = 0) {
        leftConstraint = self.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: constant)
        leftConstraint.isActive = true
    }
    
    func pinRight(view toView: UIView, _ constant: CGFloat = 0) {
        self.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: constant).isActive = true
    }
    
    func pinCenter(whatView: UIView, toView: UIView) {
        whatView.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: 0).isActive = true
    }
    
    func bounce() {
        UIView.animate(withDuration: 0.4,
                       delay: 0.1,
                       options: [.autoreverse, .repeat],
                       animations: { () -> Void in
                        //do not reverse last frame, source
                        //https://stackoverflow.com/questions/5040494/uiview-animations-with-autoreverse/11670490#11670490
                        UIView.setAnimationRepeatCount(4.5)
                        self.topConstraint.constant = 4
                        self.superview?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.4, animations: {
                self.topConstraint.constant = 0
                self.superview?.layoutIfNeeded()
            })
        })
    }
    
    func hide(_ animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.4, animations: {
                self.alpha = 0
                self.pointer.alpha = 0
            })
        } else {
            self.alpha = 0
            self.pointer.alpha = 0
        }
    }
    
    func centerTooltip(view: UIView) {
        pointer.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    }
    
    func positionTooltip() {
        let squareRoot = sqrt((20*20)+(20*20))
        pointer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -CGFloat(squareRoot/2)).isActive = true
    }
}
