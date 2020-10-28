//
//  DiscoverViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    @IBOutlet weak var charitiesView: UIView!
    @IBOutlet weak var churchesView: UIView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var artistsView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var discoverView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoundedCorners()
        setupLabels()
    }
    
    @IBAction func tappedSearch(_ sender: Any) {
        print("Search")
    }
    @IBAction func tappedDiscover(_ sender: Any) {
        print("Discover")
    }
    @IBAction func charitiesTapped(_ sender: Any) {
        print("Charities")
    }
    @IBAction func churchesTapped(_ sender: Any) {
        print("Churches")
    }
    @IBAction func actionsTapped(_ sender: Any) {
        print("Actions")
    }
    @IBAction func artistsTapped(_ sender: Any) {
        print("Artists")
    }
    
}
extension DiscoverViewController {
    func setupRoundedCorners() {
        let cornerRadius: CGFloat = 8
        for item in [charitiesView,churchesView,actionsView,artistsView,searchView,discoverView] {
            if let view = item {
                view.layer.cornerRadius = cornerRadius
            }
        }
        for item in [searchView, discoverView] {
            if let view = item {
                view.layer.borderWidth = 1
                view.layer.borderColor = ColorHelper.LightGrey.cgColor
            }
        }
    }
    func setupLabels() {
        (charitiesView.subviews[0].subviews[1] as! UILabel).text = "Stichtingen".localized
        (churchesView.subviews[0].subviews[1] as! UILabel).text = "Churches".localized
        (actionsView.subviews[0].subviews[1] as! UILabel).text = "Campaigns".localized
        (artistsView.subviews[0].subviews[1] as! UILabel).text = "Artists".localized
        (searchView.subviews[0].subviews[1] as! UILabel).text = "DiscoverSearchButton".localized
        (discoverView.subviews[0].subviews[1] as! UILabel).text = "DiscoverDiscoverButton".localized
    }
}
