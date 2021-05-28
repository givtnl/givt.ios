//
//  BaseCarouselViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 17/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class BaseCarouselViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var currentPageIndex: Int = 0
    
    var viewControllerList: [UIViewController]!
    
    var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPage = 0
        pc.numberOfPages = 0
        return pc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        setupViewControllers()
        if let firstVC = viewControllerList.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        self.view.addSubview(pageControl)
        pageControl.numberOfPages = presentationCount(for: self)
    }
    
    func setupViewControllers() {
        preconditionFailure("This is an abstract function and should be overridden")
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllerList.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vcs = pageViewController.viewControllers  {
                if let idx = viewControllerList.index(of: vcs[0]) {
                    pageControl.currentPage = idx
                    currentPageIndex = idx
                }
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else {
            return nil
        }
        let prevIndex = vcIndex - 1
        guard prevIndex >= 0 else {
            return nil
        }
        guard viewControllerList.count > prevIndex else {
            return nil
        }
        return viewControllerList[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else {return nil}
        guard viewControllerList.count > nextIndex else {return nil}
        return viewControllerList[nextIndex]
    }
    
    func loadPageAtIndex(_ index: Int) {
        let count = viewControllerList.count
        if index < count {
            if index > currentPageIndex {
                let vc = viewControllerList[index]
                self.setViewControllers([vc], direction: .forward, animated: false, completion: { (complete) -> Void in
                    self.currentPageIndex = index
                    self.pageControl.currentPage = self.currentPageIndex
                })
                
            } else if index < currentPageIndex {
                let vc = viewControllerList[index]
                self.setViewControllers([vc], direction: .reverse, animated: false, completion: { (complete) -> Void in
                    self.currentPageIndex = index
                    self.pageControl.currentPage = self.currentPageIndex
                })
                
            }
        }
    }
}

