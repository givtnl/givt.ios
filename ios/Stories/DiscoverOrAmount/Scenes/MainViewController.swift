//
//  MainViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var titleNav: UINavigationItem!
    
    private let items = ["Geef nu", "Ontdek wie"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        outerView.layer.borderWidth = 1
        outerView.layer.borderColor = UIColor.gray.cgColor
        outerView.layer.cornerRadius = 8;
        outerView.layer.masksToBounds = true;
    }
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        NotificationCenter.default.post(name: .GivtSegmentControlStateDidChange, object: nil)
    }
}

