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
    let action: ((UIViewController?)->Void)?
    
    init(image: String, color: UIColor, title: String, subText: String, action: ((UIViewController?)->Void)? = nil ) {
        self.image = image
        self.color = color
        self.title = title
        self.subText = subText
        if let actie = action {
            self.action = actie
        } else {
            self.action = nil
        }
    }
}

class Feature {
    let id: Int
    let title: String
    let notification: String
    let mustSee: Bool
    let shouldShow: ()->Bool
    let pages: [FeaturePageContent]
    
    init(id: Int, title: String, notification: String, mustSee: Bool, shouldShow: @escaping ()->Bool = { ()->Bool in return true }, pages: [FeaturePageContent]) {
        self.id = id
        self.title = title
        self.notification = notification
        self.mustSee = mustSee
        self.shouldShow = shouldShow
        self.pages = pages
    }
}

class FeatureManager {
    static let shared = FeatureManager()
    
    var featureViewConstraint: NSLayoutConstraint? = nil
    var currentContext: UIViewController? = nil
    
    let features: [Int: Feature] = [
        1: Feature( id: 1,
                    title: "Giving from the list",
                    notification: "Hi! Want to know more about giving from the list?",
                    mustSee: true,
                    pages: [
                        FeaturePageContent(image: "selectlist",
                                           color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1),
                                           title: "Giving from the list",
                                           subText: "Select an organisation from the list."),
                        FeaturePageContent(image: "sugg_actions_white",
                                           color: UIColor.darkGray,
                                           title: "Choose an amount",
                                           subText: "Just choose an amount and give")
            ]),
        2: Feature( id: 2,
                    title: "Location giving",
                    notification: "Hi! Want to know more about location giving?",
                    mustSee: false,
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
    
    var featuresWithBadge: [Int] {
        return UserDefaults.standard.featureBadges
    }
    
    var showBadge: Bool {
        return UserDefaults.standard.featureBadges.count > 0
    }
    
    public var highestFeature: Int {
        if let max = self.features.keys.max() {
            return max
        }
        return 0
    }
    
    private var lastFeatureShown: Int {
        return UserDefaults.standard.lastFeatureShown
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didShowFeature), name: .GivtDidShowFeature, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: .GivtUserDidLogin, object: nil)
    }
    
    func checkUpdateState(context: UIViewController) {
        let filteredFeatures = FeatureManager.shared.features.filter {
            $0.value.mustSee == true && $0.key > self.lastFeatureShown
        }
        var badges = UserDefaults.standard.featureBadges
        badges.append(contentsOf: features.filter { $0.key > lastFeatureShown && $0.value.mustSee && badges.firstIndex(of: $0.key) == nil }.map { $0.key })
        UserDefaults.standard.featureBadges = badges
        if badges.count > 0 && !BadgeService.shared.hasBadge(badge: .showFeature) && lastFeatureShown != -1{
            BadgeService.shared.addBadge(badge: .showFeature)
        }
        
        if highestFeature > lastFeatureShown && lastFeatureShown != -1{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { () -> Void in
                if let sv = context.navigationController?.view.superview {
                    if let featView = Bundle.main.loadNibNamed("NewFeaturePopDownView", owner: context, options: nil)?.first as! NewFeaturePopDownView? {
                        self.currentContext = context
                        featView.translatesAutoresizingMaskIntoConstraints = false
                        featView.context = context
                        sv.addSubview(featView)
                        
                        if filteredFeatures.count == 1 {
                            featView.label.text = filteredFeatures.first?.value.notification
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
                        var newTopConstraint: CGFloat = 0
                        //Need to have this for notch support
                        if #available(iOS 11.0, *){
                            newTopConstraint = 38
                        } else {
                            newTopConstraint = 24
                        }
                        UIView.animate(withDuration: 0.6, animations: {() -> Void in
                            topConstraint.constant = newTopConstraint
                            sv.layoutIfNeeded()
                        })
                        self.featureViewConstraint = topConstraint

                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {() -> Void in
                            self.dismissNotification()
                        })
                    }
                }
            })
        }
    }
    
    func dismissNotification() {
        if let topConstraint = self.featureViewConstraint {
            if let sv = currentContext!.navigationController?.view.superview {
                UIView.animate(withDuration: 0.6, animations: {() -> Void in
                    topConstraint.constant = -110
                    sv.layoutIfNeeded()
                })
            }
            self.featureViewConstraint = nil
            self.currentContext = nil
            UserDefaults.standard.lastFeatureShown = self.highestFeature
        }
    }
    
    @objc private func notificationTapped(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if let popDownview = view as? NewFeaturePopDownView {
                var featuresToShow: [Feature] = []
                var featureBadges = UserDefaults.standard.featureBadges
                for id in featureBadges {
                    featuresToShow.append(features[id]!)
                }
                for feature in features.filter({ pair in pair.key > lastFeatureShown && featuresToShow.first(where: { feat in feat.id == pair.key }) == nil }) {
                    featuresToShow.append(feature.value)
                    if feature.value.mustSee {
                        featureBadges.append(feature.key)
                    }
                }
                UserDefaults.standard.featureBadges = featureBadges
                
                if let vc = UIStoryboard(name: "Features", bundle: nil).instantiateInitialViewController() as? FeaturesNavigationController {
                    vc.btnBackVisible = false
                    vc.features = featuresToShow
                    popDownview.context?.present(vc, animated: true, completion: nil)
                }
                
                UserDefaults.standard.lastFeatureShown = self.highestFeature
            }
        }
    }
    
    func getViewControllerForFeature(feature: Int) -> FeaturesNavigationController? {
        if let vc = UIStoryboard(name: "Features", bundle: nil).instantiateInitialViewController() as? FeaturesNavigationController {
            if let feature = features.first(where: { $0.key == feature }) {
                vc.features = [feature.value]
                return vc
            }
        }
        return nil
    }
    
    @objc private func didShowFeature(notification: NSNotification) {
        if let featureId = notification.userInfo?["id"] as? Int {
            var featureBadges = UserDefaults.standard.featureBadges
            if let badge = featureBadges.firstIndex(of: featureId) {
                featureBadges.remove(at: badge)
                UserDefaults.standard.featureBadges = featureBadges
                if featureBadges.count == 0 {
                    BadgeService.shared.removeBadge(badge: .showFeature)
                }
            }
        }
    }
    
    @objc private func userDidLogin(notification: NSNotification) {
        UserDefaults.standard.lastFeatureShown = self.highestFeature
    }
}
