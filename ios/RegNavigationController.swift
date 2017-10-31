//
//  RegistrationNavigationController.swift
//  ios
//
//  Created by Lennie Stockman on 22/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class RegNavigationController: UINavigationController {

    enum StartPoint {
        case permission
        case amountLimit
        case mandate
    }
    
    var startPoint: StartPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = saveImage()
        self.navigationBar.setBackgroundImage(img, for: .default)
        self.navigationBar.shadowImage = UIImage()
        print(self.navigationBar.frame.width)
        //self.navigationBar.topItem?.titleView = UIImageView(image: #imageLiteral(resourceName: "givt20h.png"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if startPoint == .permission {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
            vc.hasBackButton = true
            self.setViewControllers([vc], animated: false)
        } else if startPoint == .amountLimit {
            let vc = storyboard?.instantiateViewController(withIdentifier: "alvcreg") as! AmountLimitViewController
            vc.hasBackButton = true
            vc.isRegistration = true
            self.setViewControllers([vc], animated: false)
        } else if startPoint == .mandate {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SPInfoViewController") as! SPInfoViewController
            vc.hasBackButton = true
            self.setViewControllers([vc], animated: false)
        }
    }
    
  
    @IBOutlet var navBar: UINavigationBar!
    


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print(segue.destination.nibName)
        
    }
    
    func saveImage() -> UIImage {
        let bottomImage = UIImage()
        let topImage = #imageLiteral(resourceName: "givt20h.png")
        let navBarWidth = self.navigationBar.frame.width
        let navBarHeight = self.navigationBar.frame.height
        let diff = UIScreen.main.bounds.height - self.view.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height - diff
        let newSize = CGSize(width: navBarWidth, height: navBarHeight + statusBarHeight) // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let x = (newSize.width / 2) - (topImage.size.width / 2)
        let y = (navBarHeight / 2) - (topImage.size.height / 2) + statusBarHeight
        topImage.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: topImage.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
