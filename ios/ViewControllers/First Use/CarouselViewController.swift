//
//  CarouselViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class CarouselViewController: BaseCarouselViewController {
    
    func createPage(title: String, subtitle: String, image: UIImage) -> TemplateViewController {
        
        let storyboard = UIStoryboard.init(name: "Welcome", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "template") as! TemplateViewController
        vc.sTitle = title
        vc.subtitle = subtitle
        vc.uImage = image
        return vc
    }
    
    override func setupViewControllers() {
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
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.831372549, green: 0.8352941176, blue: 0.8666666667, alpha: 1)
        pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
}
