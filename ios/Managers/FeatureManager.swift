//
//  NewFeatureManager.swift
//  ios
//
//  Created by Maarten Vergouwe on 14/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class FeaturePageContent {
    let image: String
    let color: UIColor
    let title: String
    let subText: String
    let action: (UIViewController?)->Void

    init(image: String, color: UIColor, title: String, subText: String, action: @escaping (UIViewController?)->Void = {(_) in } ) {
        self.image = image
        self.color = color
        self.title = title
        self.subText = subText
        self.action = action
    }
}

class Feature {
    let id: Int
    let notification: String
    let mustSee: Bool
    let shouldShow: ()->Bool
    let pages: [FeaturePageContent]
    
    init(id: Int, notification: String, mustSee: Bool, shouldShow: @escaping ()->Bool = { ()->Bool in return true }, pages: [FeaturePageContent]) {
        self.id = id
        self.notification = notification
        self.mustSee = mustSee
        self.shouldShow = shouldShow
        self.pages = pages
    }
}

class FeatureManager {
    static let shared = FeatureManager()

    let features: Dictionary<Int, Feature> = [
        1: Feature( id: 1,
                    notification: "Hi! Want to know more about location giving?",
                    mustSee: true,
                    pages: [
                        FeaturePageContent(image: "lookoutgivy",
                                           color: UIColor.red,
                                           title: "Location giving",
                                           subText: "The Givt-app can detect where you are by accessing your location data."),
                        FeaturePageContent(image: "sugg_actions_white",
                                           color: UIColor.purple,
                                           title: "Choose an amount",
                                           subText: "Just choose an amount and give",
                                           action: {(context) -> Void in
                                                let alert = UIAlertController(title: NSLocalizedString("AmountTooLow", comment: ""), message: "Jaja, kwetet", preferredStyle: UIAlertControllerStyle.alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
                                                context!.present(alert, animated: true, completion: {})
                                           })
                        ])
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
                        featView.context = context
                        sv.addSubview(featView)
                        
                        if self.highestFeature - UserDefaults.standard.lastFeatureShown == 1 {
                            featView.label.text = self.features[self.highestFeature]?.notification
                        }
                        
                        featView.tapGesture.addTarget(self, action: #selector(self.notificationTapped))
                        
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
                                //UserDefaults.standard.lastFeatureShown = self.highestFeature
                            })
                        })
                    }
                }
            })
        }
    }
    
    @objc func notificationTapped(_ recognizer: UITapGestureRecognizer) {
        if let vc = UIStoryboard(name: "Features", bundle: nil).instantiateInitialViewController() as? FeaturesFirstViewController{
            if let view = recognizer.view {
                if let popDownview = view as? NewFeaturePopDownView {
                    vc.featurePages = self.features[1]?.pages
                    popDownview.context?.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
}
