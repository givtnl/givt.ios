//
//  DiscoverOrAmountPageViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

class InitialPageViewController: UIPageViewController {
    fileprivate var items: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(segmentControlTapped), name: .GivtSegmentControlStateDidChange, object: nil)
        dataSource = self
        delegate = self
        
        populateItems()
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension InitialPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == items[1] {
            return items[0]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == items[0] {
            return items[1]
        }
        return nil
    }
    
    //both didFinishAnimating and willTransitionTo are needed to have a correct state
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let mainController = pageViewController.parent as? MainViewController {
            if previousViewControllers[0] == items[0] {
                if completed {
                    mainController.segmentControl.selectedSegmentIndex = 1
                    navigationController?.children.first?.title = "DiscoverHomeDiscoverTitle".localized
                } else {
                    mainController.segmentControl.selectedSegmentIndex = 0
                    navigationController?.children.first?.title = "Amount".localized
                }
            } else {
                if completed {
                    mainController.segmentControl.selectedSegmentIndex = 0
                    navigationController?.children.first?.title = "Amount".localized
                } else {
                    mainController.segmentControl.selectedSegmentIndex = 1
                    navigationController?.children.first?.title = "DiscoverHomeDiscoverTitle".localized
                }
            }
        }
    }
    
    @objc func segmentControlTapped() {
        if viewControllers?.count == 1 {
            if viewControllers?[0] is AmountViewController {
                navigationController?.children.first?.title = "DiscoverHomeDiscoverTitle".localized
                setViewControllers([items[1]], direction: .forward, animated: true, completion: nil)
            } else {
                navigationController?.children.first?.title = "Amount".localized
                setViewControllers([items[0]], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func populateItems() {
        let vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AmountViewController") as! AmountViewController
        let vc2 = UIStoryboard(name: "DiscoverOrAmount", bundle: nil).instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
        items.append(vc1)
        items.append(vc2)
    }
}
