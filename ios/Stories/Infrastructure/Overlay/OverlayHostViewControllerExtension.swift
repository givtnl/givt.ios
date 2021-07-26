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
    func showOverlay<T: OverlayViewController>(type: T.Type, fromStoryboardWithName storyboardName: String, collections: [AnyObject]?, completion: @escaping OverlayHostCompletion) -> T?
    func showOverlay<T: OverlayViewController>(identifier: String, fromStoryboardWithName storyboardName: String, collections: [AnyObject]?, completion: @escaping OverlayHostCompletion) -> T?
}

typealias OverlayHostCompletion =  () -> Void

extension OverlayHost where Self: UIViewController {
    @discardableResult
    func showOverlay<T: OverlayViewController>(type: T.Type, fromStoryboardWithName storyboardName: String, collections: [AnyObject]? = nil, completion: @escaping OverlayHostCompletion) -> T? {
        let identifier = String(describing: T.self)
        return showOverlay(identifier: identifier, fromStoryboardWithName: storyboardName, collections: collections, completion: completion)
    }

    @discardableResult
    func showOverlay<T: OverlayViewController>(identifier: String, fromStoryboardWithName storyboardName: String, collections: [AnyObject]? = nil, completion: @escaping OverlayHostCompletion) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let overlay = storyboard.instantiateViewController(withIdentifier: identifier) as? T else { return nil }
        if overlay is BudgetListViewController {
            if let items = collections {
                if let givtModels = items[0] as? [MonthlySummaryDetailModel] {
                    (overlay as! BudgetListViewController).collectGroupsForCurrentMonth = givtModels
                }
                if let notGivtModels = items[1] as? [ExternalDonationModel] {
                    (overlay as! BudgetListViewController).notGivtModelsForCurrentMonth = notGivtModels
                }
                if let date = items[2] as? Date {
                    (overlay as! BudgetListViewController).monthDate = date
                }
            }
        }
        overlay.completion = completion
        overlay.presentOverlay(from: self)
        return overlay
    }
}
