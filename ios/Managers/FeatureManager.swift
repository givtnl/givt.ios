//
//  NewFeatureManager.swift
//  ios
//
//  Created by Maarten Vergouwe on 14/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class Feature {
    let id: Int
    let notification: String
    let image: String
    let color: UIColor
    let title: String
    let subText: String
    let mustSee: Bool
    
    init(id: Int, notification: String, image: String, color: UIColor, title: String, subText: String, mustSee: Bool) {
        self.id = id
        self.notification = notification
        self.image = image
        self.color = color
        self.title = title
        self.subText = subText
        self.mustSee = mustSee
    }
}

class FeatureManager {
    static let shared = FeatureManager()

    let features: Dictionary<Int, Feature> = [
        1: Feature(id: 1, notification: "This is feature notification", image: "image.png", color: UIColor.red, title: "Title", subText: "This is the text with explanation about the feature", mustSee: true)
    ]
    
    var highestFeature: Int = 0
    
    init() {
        if let max = self.features.keys.max() {
            highestFeature = max
        }
    }
    
    func checkUpdateState(context: UIViewController) {
        if highestFeature > UserDefaults.standard.lastFeatureShown {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { () -> Void in
                if let sv = context.navigationController?.view.superview {
                    if let featView = Bundle.main.loadNibNamed("NewFeaturePopDownView", owner: context, options: nil)?.first as! NewFeaturePopDownView? {
                        featView.translatesAutoresizingMaskIntoConstraints = false
                        sv.addSubview(featView)
                        
                        if self.highestFeature - UserDefaults.standard.lastFeatureShown == 1 {
                            featView.label.text = self.features[self.highestFeature]?.notification
                        }
                        
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
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {() -> Void in
                            UIView.animate(withDuration: 0.6, animations: {() -> Void in
                                topConstraint.constant = -110
                                sv.layoutIfNeeded()
                                UserDefaults.standard.lastFeatureShown = self.highestFeature
                            })
                        })
                    }
                }
            })
        }
    }
}
