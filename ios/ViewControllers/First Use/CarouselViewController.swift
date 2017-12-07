//
//  CarouselViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class CarouselViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var viewControllerList: [UIViewController]!
    
    var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPage = 0
        pc.numberOfPages = 0
        pc.currentPageIndicatorTintColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        pc.pageIndicatorTintColor = #colorLiteral(red: 0.831372549, green: 0.8352941176, blue: 0.8666666667, alpha: 1)
        return pc
    }()
    
    func createPage(title: String, subtitle: String, image: UIImage) -> TemplateViewController {
        
        let storyboard = UIStoryboard.init(name: "Welcome", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "template") as! TemplateViewController
        vc.sTitle = title
        vc.subtitle = subtitle
        vc.uImage = image
        return vc
    }
    
    func setupViewControllers() {
        let welcomeGivy: UIImage
        if let code = Locale.current.languageCode, code == "nl" {
            welcomeGivy = #imageLiteral(resourceName: "givy_welkom")
        } else {
            welcomeGivy = #imageLiteral(resourceName: "givy_welkom_en")
        }
        let welcome = createPage(title: NSLocalizedString("FirstUseWelcomeTitle", comment: ""), subtitle: NSLocalizedString("FirstUseWelcomeSubTitle", comment: ""), image: welcomeGivy)
        let register = createPage(title: NSLocalizedString("FirstUseLabelTitle1", comment: ""), subtitle: "", image: #imageLiteral(resourceName: "givy_register"))
        let collection = createPage(title: NSLocalizedString("FirstUseLabelTitle2", comment: ""), subtitle: "", image: #imageLiteral(resourceName: "firstuse_select"))
        let types = createPage(title: NSLocalizedString("FirstUseLabelTitle3", comment: ""), subtitle: "", image: #imageLiteral(resourceName: "firstuse_orgs"))
        
        viewControllerList = [welcome, register, collection, types]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        // Do any additional setup after loading the view.
        
        setupViewControllers()
        
        if let firstVC = viewControllerList.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        self.view.addSubview(pageControl)
        pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        pageControl.numberOfPages = presentationCount(for: self)
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllerList.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentVC = pageViewController.viewControllers![0] as? UIViewController {
                if let idx = viewControllerList.index(of: currentVC) {
                    pageControl.currentPage = idx
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

}
