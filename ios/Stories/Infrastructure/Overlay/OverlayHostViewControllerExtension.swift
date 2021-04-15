//
//  OverlayHostViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

// if you want to implement the overlay on a controller, inherit the OverlayHost on that controller
protocol OverlayHost {
    func showOverlay<T: OverlayViewController>(type: T.Type, fromStoryboardWithName storyboardName: String) -> T?
    func showOverlay<T: OverlayViewController>(identifier: String, fromStoryboardWithName storyboardName: String) -> T?
}

extension OverlayHost where Self: UIViewController {
    @discardableResult
    func showOverlay<T: OverlayViewController>(type: T.Type, fromStoryboardWithName storyboardName: String) -> T? {
        let identifier = String(describing: T.self)
        return showOverlay(identifier: identifier, fromStoryboardWithName: storyboardName)
    }

    @discardableResult
    func showOverlay<T: OverlayViewController>(identifier: String, fromStoryboardWithName storyboardName: String) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let overlay = storyboard.instantiateViewController(withIdentifier: identifier) as? T else { return nil }
        overlay.presentOverlay(from: self)
        return overlay
    }
}
