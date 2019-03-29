//
//  ChooseContextViewController.swift
//  ios
//
//  Created by Lennie Stockman on 5/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import CoreLocation

class ChooseContextViewController: UIViewController {
   
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtextLabel: UILabel!
    
    @IBOutlet var firstSelection: SelectContextView!
    @IBOutlet var secondSelection: SelectContextView!
    @IBOutlet var thirdSelection: SelectContextView!
    @IBOutlet var fourthSelection: SelectContextView!
    
    lazy var contexts: [Context] = {
        let collectionDevice = Context(title: NSLocalizedString("GivingContextCollectionBag", comment: ""), subtitle: NSLocalizedString("SelectContextCollect", comment: ""), type: ContextType.collectionDevice, image: #imageLiteral(resourceName: "collectebus_grijs"))
        let qr = Context(title: NSLocalizedString("GivingContextQRCode", comment: ""), subtitle: NSLocalizedString("GiveContextQR", comment: ""), type: ContextType.qr, image: #imageLiteral(resourceName: "qr_scan_phone_grijs"))
        let list = Context(title: NSLocalizedString("GivingContextCollectionBagList", comment: ""),subtitle: NSLocalizedString("SelectContextList", comment: ""), type: ContextType.manually, image: #imageLiteral(resourceName: "selectlist_grijs"))
        let location = Context(title: NSLocalizedString("GivingContextLocation", comment: ""), subtitle: NSLocalizedString("SelectLocationContextLong", comment: ""), type: ContextType.events, image: #imageLiteral(resourceName: "locatie_grijs"))
    return [collectionDevice, qr, list, location]
    }()
    
    func showBluetoothMessage() {
        let alert = UIAlertController(
            title: NSLocalizedString("ActivateBluetooth", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessage", comment: "") + "\n\n" + NSLocalizedString("ExtraBluetoothText", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .default, handler: { action in

        }))
        present(alert, animated: true, completion: nil)
    }


    @IBAction func selectContext(_ sender: Any) {
        let contextType = (sender as! SelectContextView).contextType
        let sb = UIStoryboard(name:"Main", bundle:nil)
        DispatchQueue.main.async {
            switch contextType! {
            case .collectionDevice:
                if GivtManager.shared.isBluetoothEnabled || TARGET_OS_SIMULATOR != 0 {
                    let vc = sb.instantiateViewController(withIdentifier: "scanView") as! ScanViewController
                    self.navigationController!.show(vc, sender: nil)
                } else {
                    self.showBluetoothMessage()
                }
            case .qr:
                let vc = sb.instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                self.navigationController!.show(vc, sender: nil)
            case .manually:
                let vc = sb.instantiateViewController(withIdentifier: "ManualGivingViewController") as! ManualGivingViewController
                self.navigationController!.show(vc, sender: nil)
            case .events:
                if !GivtManager.shared.hasGivtLocations() {
                    let alert = UIAlertController(title: NSLocalizedString("GivtAtLocationDisabledTitle", comment: ""), message: NSLocalizedString("GivtAtLocationDisabledMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
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
        
        titleLabel.text = NSLocalizedString("SelectContext", comment: "")

        subtextLabel.text = NSLocalizedString("GiveSubtitle", comment: "")
        subtextLabel.adjustsFontSizeToFitWidth = true
        
        for (index, element) in contexts.enumerated() {
            switch index {
                case 0:
                    firstSelection.title.text = element.title
                    firstSelection.content.text = element.subtitle
                    firstSelection.image.image = element.image
                    firstSelection.contextType = element.type
                case 1:
                    secondSelection.title.text = element.title
                    secondSelection.content.text = element.subtitle
                    secondSelection.image.image = element.image
                    secondSelection.contextType = element.type
                case 2:
                    thirdSelection.title.text = element.title
                    thirdSelection.content.text = element.subtitle
                    thirdSelection.image.image = element.image
                    thirdSelection.contextType = element.type
                case 3:
                    fourthSelection.title.text = element.title
                    fourthSelection.content.text = element.subtitle
                    fourthSelection.image.image = element.image
                    fourthSelection.contextType = element.type
            default:
                return
            }
            
            if !GivtManager.shared.hasGivtLocations() && element.type == .events {
                fourthSelection.alpha = 0.4
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_second"))
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
}

