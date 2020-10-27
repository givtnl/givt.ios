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
extension InitialPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return items.last
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        
        return items[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard items.count != nextIndex else {
            return items.first
        }
        
        guard items.count > nextIndex else {
            return nil
        }
        
        return items[nextIndex]
    }
    
    
}
