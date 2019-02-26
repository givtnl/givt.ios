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
   
//    @IBOutlet var giveSubtitle: UILabel!
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
        let location = Context(title: NSLocalizedString("GivingContextLocation", comment: ""), subtitle: NSLocalizedString("SelectLocationContextLong", comment: ""), type: ContextType.events, image: #imageLiteral(resourceName: "locatie_grijs"))
        let list = Context(title: NSLocalizedString("GivingContextCollectionBagList", comment: ""),subtitle: NSLocalizedString("SelectContextList", comment: ""), type: ContextType.manually, image: #imageLiteral(resourceName: "selectlist_grijs"))
    return !GivtManager.shared.hasGivtLocations() ? [collectionDevice, qr, list, location] : [collectionDevice, qr, location, list]
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
        
//
//        let hasGivtLocations = GivtManager.shared.hasGivtLocations()
//        contexts.forEach { (context) in
//            let containerView = UIView()
//            containerView.isUserInteractionEnabled = true
//            let tap = ContextTapGesture(target: self, action: #selector(pressedRow))
//            tap.contextType = context.type
//            containerView.addGestureRecognizer(tap)
//            containerView.translatesAutoresizingMaskIntoConstraints = false
//            containerView.backgroundColor = #colorLiteral(red: 0.8232886195, green: 0.8198277354, blue: 0.8529217839, alpha: 0.8036708048)
//            contextsStackView.addArrangedSubview(containerView)
//
//            let stackView = UIStackView()
//            stackView.spacing = 10
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//            stackView.axis = .horizontal
//            containerView.addSubview(stackView)
//            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
//            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
//            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5).isActive = true
//            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
//            let img = UIImageView(image: context.image)
//            img.contentMode = .scaleAspectFit
//            stackView.addArrangedSubview(img)
//            img.widthAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
//            let label = UILabel()
//            label.adjustsFontSizeToFitWidth = true
//            label.minimumScaleFactor = 0.6
//            label.numberOfLines = 0
//            label.textAlignment = .center
//            label.translatesAutoresizingMaskIntoConstraints = false
//            label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
//            label.attributedText = makeAttributedString(title: context.title, subtitle: context.subtitle)
//            stackView.addArrangedSubview(label)
//            let arrow = UIImageView(image: #imageLiteral(resourceName: "rightarrow-purple"))
//            arrow.translatesAutoresizingMaskIntoConstraints = false
//            arrow.contentMode = .scaleAspectFit
//            stackView.addArrangedSubview(arrow)
//            arrow.widthAnchor.constraint(equalToConstant: 12).isActive = true
//
//            if !hasGivtLocations && context.type == .events {
//                containerView.alpha = 0.4
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
//        navigationController?.navigationBar.isTranslucent = true
//        
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.init(rgb: 0x2E2957), NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17)!]
        
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
}

//class ContextTapGesture: UITapGestureRecognizer {
//    var contextType: ContextType!
//}
