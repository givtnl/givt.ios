//
//  NewFeatureManager.swift
//  ios
//
//  Created by Maarten Vergouwe on 14/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class NewFeatureManager {
    static var shared = NewFeatureManager()
    
    func checkUpdateState(context: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { () -> Void in
            if let sv = context.navigationController?.view.superview {
                if let featView = Bundle.main.loadNibNamed("NewFeaturePopDownView", owner: context, options: nil)?.first as! NewFeaturePopDownView? {
                    featView.translatesAutoresizingMaskIntoConstraints = false
                    sv.addSubview(featView)
                    let topConstraint = featView.topAnchor.constraint(equalTo: sv.topAnchor, constant: -110)
                    NSLayoutConstraint.activate([
                        featView.widthAnchor.constraint(equalToConstant: sv.frame.width-16),
                        featView.leftAnchor.constraint(equalTo: sv.leftAnchor, constant: 8),
                        topConstraint
                        ])
                    sv.layoutIfNeeded()
                    featView.invalidateIntrinsicContentSize()
                    sv.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.6, animations: {() -> Void in
                        topConstraint.constant = 38
                        sv.layoutIfNeeded()
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {() -> Void in
                        UIView.animate(withDuration: 0.6, animations: {() -> Void in
                            topConstraint.constant = -110
                            sv.layoutIfNeeded()
                        })
                    })
                }
            }
        })
    }
}
