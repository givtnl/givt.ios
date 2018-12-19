//
//  FeaturesFirstViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 18/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class FeaturesFirstViewController: UIViewController {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var btnSkip: CustomButton!
    
    var btnBackVisible = true
    var btnCloseVisible = true
    var btnSkipVisible = true
    
    var featurePages: [FeaturePageContent]? = nil

    override func viewWillAppear(_ animated: Bool) {
        navItem.leftBarButtonItem = btnBackVisible ? navItem.leftBarButtonItem : nil
        navItem.rightBarButtonItem = btnCloseVisible ? navItem.rightBarButtonItem : nil
        btnSkip.isHidden = !btnSkipVisible
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedFeaturesCarousel" {
            if let destinationVc = segue.destination as? FeatureCarouselViewController {
                destinationVc.contentPages = featurePages
            }
        }
    }

    @IBAction func btnCloseTapped(_ sender: Any) {
        DispatchQueue.main.async {
            FeatureManager.shared.dismissNotification()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
