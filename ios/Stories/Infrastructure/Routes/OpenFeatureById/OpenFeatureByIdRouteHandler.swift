//
//  OpenFeatureByIdRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 24/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class OpenFeatureByIdRouteHandler : RequestHandlerWithContextProtocol {
    private let slideFromRightAnimation = PresentFromRight()

    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        if (request as! OpenFeatureByIdRoute).featureId > FeatureManager.shared.highestFeature {
            let updateViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowUpdateFeatureViewController") as! ShowUpdateFeatureViewController
            updateViewController.modalPresentationStyle = .fullScreen
            updateViewController.transitioningDelegate = slideFromRightAnimation
            DispatchQueue.main.async {
                context.present(updateViewController, animated: true, completion: nil)
            }
        } else {
            if let vc = FeatureManager.shared.getViewControllerForFeature(feature: (request as! OpenFeatureByIdRoute).featureId) {
                vc.transitioningDelegate = slideFromRightAnimation
                vc.btnCloseVisible = false
                vc.btnSkipVisible = false
                vc.modalPresentationStyle = .fullScreen
                
                DispatchQueue.main.async {
                    context.present(vc, animated: true, completion: nil)
                }
            }
        }
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenFeatureByIdRoute
    }
}
