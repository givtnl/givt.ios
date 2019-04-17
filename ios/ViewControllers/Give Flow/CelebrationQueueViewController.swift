//
//  CelebrationQueueViewController.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UIKit

class CelebrationQueueViewController : UIViewController {
    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var secondaryTitelLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        navigationItem.title = "Queue titel"
        titelLabel.text = "Titel Label Queue"
        secondaryTitelLabel.text = "Secondary Titel Label Queue"
        imageView.image = #imageLiteral(resourceName: "givy_flashlight_frame")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_fourth"))
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
}
