//
//  DiscoverOrAmountPageViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

class InitialPageViewController: UIPageViewController {
    @objc func segmentControlTapped() {
        if viewControllers?.count == 1 {
            if viewControllers?[0] is AmountViewController {
                setViewControllers([items[1]], direction: .forward, animated: true, completion: nil)
            } else {
                setViewControllers([items[0]], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate var items: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(segmentControlTapped), name: .GivtSegmentControlStateDidChange, object: nil)

        dataSource = self

        populateItems()
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    fileprivate func populateItems() {
        let vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AmountViewController") as! AmountViewController
        let vc2 = UIStoryboard(name: "DiscoverOrAmount", bundle: nil).instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
        items.append(vc1)
        items.append(vc2)
    }
}
extension InitialPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is AmountViewController {
            return items[1]
        } else {
            return items[0]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is AmountViewController {
            return items[1]
        } else {
            return items[0]
        }
    }
    
    
}
