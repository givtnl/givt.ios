//
//  CustomModalAnimation.swift
//  ios
//
//  Created by Lennie Stockman on 6/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class CustomPresentModalAnimation: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    let duration = 0.25
    let customDismiss = CustomDismissModalAnimation()
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
        let screenOffUp = CGAffineTransform(translationX: 0, y: -container.frame.height)
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        toView.transform = screenOffUp
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            toView.transform = CGAffineTransform.identity
            toView.alpha = 1
            
        }) { (success) in
            transitionContext.completeTransition(success)
        }
        
    }
}

class CustomDismissModalAnimation: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
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
        let screenOffUp = CGAffineTransform(translationX: 0, y: -container.frame.height)

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
