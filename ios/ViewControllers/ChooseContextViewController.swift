//
//  ChooseContextViewController.swift
//  ios
//
//  Created by Lennie Stockman on 5/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import CoreLocation
import AppCenterAnalytics
import Mixpanel

class ChooseContextViewController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet var subtextLabel: UILabel!
    
    @IBOutlet var firstSelection: SelectContextView!
    @IBOutlet var secondSelection: SelectContextView!
    @IBOutlet var thirdSelection: SelectContextView!
    @IBOutlet var fourthSelection: SelectContextView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    lazy var contexts: [Context] = {
        let collectionDevice = Context(title: NSLocalizedString("GivingContextCollectionBag", comment: ""), subtitle: NSLocalizedString("SelectContextCollect", comment: ""), type: ContextType.GiveWithBluetooth, image: #imageLiteral(resourceName: "collectebus_grijs"))
        let qr = Context(title: NSLocalizedString("GivingContextQRCode", comment: ""), subtitle: NSLocalizedString("GiveContextQR", comment: ""), type: ContextType.GiveWithQR, image: #imageLiteral(resourceName: "qr_scan_phone_grijs"))
        let list = Context(title: NSLocalizedString("GivingContextCollectionBagList", comment: ""),subtitle: NSLocalizedString("SelectContextList", comment: ""), type: ContextType.GiveFromList, image: #imageLiteral(resourceName: "selectlist_grijs"))
        let location = Context(title: NSLocalizedString("GivingContextLocation", comment: ""), subtitle: NSLocalizedString("SelectLocationContextLong", comment: ""), type: ContextType.GiveToEvent, image: #imageLiteral(resourceName: "locatie_grijs"))
    return [collectionDevice, qr, list, location]
    }()
    
    @IBAction func selectContext(_ sender: Any) {
        let contextType = (sender as! SelectContextView).contextType
        Analytics.trackEvent("CONTEXT_SELECTED", withProperties:["context": contextType!.name])
        Mixpanel.mainInstance().track(event: "CONTEXT_SELECTED", properties: ["context": contextType!.name])
        let sb = UIStoryboard(name:"Main", bundle:nil)
        DispatchQueue.main.async {
            switch contextType! {
            case .GiveWithBluetooth:
                let vc = sb.instantiateViewController(withIdentifier: "scanView") as! ScanViewController
                self.navigationController!.show(vc, sender: nil)
            case .GiveWithQR:
                let vc = sb.instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                self.navigationController!.show(vc, sender: nil)
            case .GiveFromList:
                let vc = sb.instantiateViewController(withIdentifier: "SelectOrgViewController") as! SelectOrgViewController
                self.navigationController!.show(vc, sender: nil)
            case .GiveToEvent:
                if !GivtManager.shared.hasGivtLocations() {
                    let alert = UIAlertController(title: NSLocalizedString("GivtAtLocationDisabledTitle", comment: ""), message: NSLocalizedString("GivtAtLocationDisabledMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.navigationController?.present(alert, animated: true, completion: nil)
                } else {
                    let story = UIStoryboard(name: "Event", bundle: nil)
                    let vc = story.instantiateInitialViewController() as! EventViewController
                    self.navigationController?.show(vc, sender: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        
        navigationTitle.title = NSLocalizedString("SelectContext", comment: "")

        subtextLabel.text = NSLocalizedString("GiveSubtitle", comment: "")
        subtextLabel.adjustsFontSizeToFitWidth = true
        
        for (index, element) in contexts.enumerated() {
            switch index {
                case 0:
                    firstSelection.title.text = element.title
                    firstSelection.content.text = element.subtitle
                    firstSelection.image.image = element.image
                    firstSelection.contextType = element.type
                    firstSelection.contentView.accessibilityLabel = element.subtitle
                case 1:
                    secondSelection.title.text = element.title
                    secondSelection.content.text = element.subtitle
                    secondSelection.image.image = element.image
                    secondSelection.contextType = element.type
                    secondSelection.contentView.accessibilityLabel = element.subtitle
                case 2:
                    thirdSelection.title.text = element.title
                    thirdSelection.content.text = element.subtitle
                    thirdSelection.image.image = element.image
                    thirdSelection.contextType = element.type
                    thirdSelection.contentView.accessibilityLabel = element.subtitle
                case 3:
                    fourthSelection.title.text = element.title
                    fourthSelection.content.text = element.subtitle
                    fourthSelection.image.image = element.image
                    fourthSelection.contextType = element.type
                    fourthSelection.contentView.accessibilityLabel = element.subtitle
            default:
                return
            }
            
            if !GivtManager.shared.hasGivtLocations() && element.type == .GiveToEvent {
                fourthSelection.alpha = 0.4
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
}

