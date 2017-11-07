//
//  ManualOrganisationView.swift
//  ios
//
//  Created by Lennie Stockman on 6/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit

class ManualOrganisationView: UIView {
    var showCheckMark: Bool = false
    var checkMark: UIImageView!
    var stack: UIStackView!
    var label: UILabel!
    var organisationId: String!
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }
    
    convenience init(text: String, orgId: String){
        self.init(frame: CGRect.zero) // calls the initializer above
        self.organisationId = orgId
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        addStackview(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addStackview(_ text: String) {
        
        stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)
        stack.axis = .horizontal
        stack.spacing = 20
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.backgroundColor = .red
        
        addCheck()
        addLabel(text)
    }
    
    private func addLabel(_ text: String) {
        label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 19.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        label.numberOfLines = 0
        label.textAlignment = .left
        stack.addArrangedSubview(label)
    }
    
    private func addPlaceholderCheck() {
        
    }
    
    private func addPlaceholderImg(_ view: UIView) {
        checkMark = UIImageView()
        checkMark.contentMode = .scaleAspectFit
        checkMark.image = #imageLiteral(resourceName: "check_green")
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        checkMark.widthAnchor.constraint(equalToConstant: 21.0).isActive = true
        checkMark.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        checkMark.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        showCheckMark = false
        checkMark.isHidden = true
    }
    
    private func addCheck() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(view)
        view.widthAnchor.constraint(equalToConstant: 21).isActive = true
        
        
        let placeholder = UIImageView()
        view.addSubview(placeholder)
        placeholder.contentMode = .scaleAspectFit
        placeholder.image = #imageLiteral(resourceName: "check_green")
        placeholder.alpha = 0
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.widthAnchor.constraint(equalToConstant: 21.0).isActive = true
        placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        checkMark = UIImageView()
        view.addSubview(checkMark)
        checkMark.contentMode = .scaleAspectFit
        //stack.addArrangedSubview(checkMark)
        checkMark.image = #imageLiteral(resourceName: "check_green")
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        checkMark.widthAnchor.constraint(equalToConstant: 21.0).isActive = true
        checkMark.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        checkMark.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        showCheckMark = false
        checkMark.isHidden = true
    }
    
    func toggleCheckMark() {
        showCheckMark = !showCheckMark
        checkMark.isHidden = !showCheckMark
        self.backgroundColor = showCheckMark ? #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9333333333, alpha: 1) : .white
        self.label.font = showCheckMark ? UIFont(name: "Avenir-Heavy", size: 19.0) : UIFont(name: "Avenir-Medium", size: 19.0)
    }

}
