//
//  RegistrationNavigationController.swift
//  ios
//
//  Created by Lennie Stockman on 22/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class RegNavigationController: UINavigationController {

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
    
  
    @IBOutlet var navBar: UINavigationBar!
    


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func saveImage() -> UIImage {
        let bottomImage = UIImage()
        let topImage = #imageLiteral(resourceName: "givt20h.png")
        let navBarWidth = self.navigationBar.frame.width
        let navBarHeight = self.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let newSize = CGSize(width: navBarWidth, height: navBarHeight + statusBarHeight) // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        bottomImage.draw(in: CGRect(origin: CGPoint(x: statusBarHeight, y: 0), size: newSize))//As drawInRect is deprecated
        
        let x = (newSize.width / 2) - (topImage.size.width / 2)
        let y = statusBarHeight + (navBarHeight / 2) - (topImage.size.height / 2)
        topImage.draw(at: CGPoint(x: x,y: y))//As drawInRect is deprecated
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    

}
