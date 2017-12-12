//
//  ModalFromRightAnimation.swift
//  ios
//
//  Created by Lennie Stockman on 11/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
//
//  CustomModalAnimation.swift
//  ios
//
//  Created by Lennie Stockman on 6/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class PresentFromRight: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    let duration = 0.25
    let customDismiss = HideFromRight()
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customDismiss
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            return
        }
        
        let container = transitionContext.containerView
        let screenOffUp = CGAffineTransform(translationX: container.frame.width, y: 0)
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        toView.transform = screenOffUp
        toView.dropShadow()
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            toView.transform = CGAffineTransform.identity
            toView.alpha = 1
            
        }) { (success) in
            transitionContext.completeTransition(success)
        }
        
    }

}

class HideFromRight: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    let duration = 0.25
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            return
        }
        
        let container = transitionContext.containerView
        let screenOffUp = CGAffineTransform(translationX: container.frame.width, y: 0)
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        fromView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            fromView.transform = screenOffUp
        }) { (success) in
            transitionContext.completeTransition(success)
        }
        
    }
}
