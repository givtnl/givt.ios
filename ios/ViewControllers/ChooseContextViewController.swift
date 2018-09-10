//
//  ChooseContextViewController.swift
//  ios
//
//  Created by Lennie Stockman on 5/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import CoreLocation

class ChooseContextViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet var giveSubtitle: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var contextsStackView: UIStackView!
    
    let lightAttributes = [
        NSAttributedStringKey.font: UIFont(name: "Avenir-Light", size: 17)!,
        NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        ] as [NSAttributedStringKey : Any]
    let boldAttributes = [
        NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17)!,
        NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        ] as [NSAttributedStringKey : Any]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseContextTableViewCell") as! ChooseContextTableViewCell
        cell.name.text = contexts[indexPath.row].subtitle
        //cell.subtext.text = contexts[indexPath.row].explanation
        cell.img.image = contexts[indexPath.row].image
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.contextType = contexts[indexPath.row].type
        if cell.contextType! == ContextType.events {
            cell.contentView.alpha = !GivtManager.shared.hasGivtLocations() ? 0.5 : 1
        }
        switch cell.contextType! {
        case .collectionDevice:
            cell.name.attributedText = makeAttributedString(title: NSLocalizedString("GivingContextCollectionBag", comment: ""), subtitle: NSLocalizedString("SelectContextCollect", comment: ""))
        case .qr:
            cell.name.attributedText = makeAttributedString(title: NSLocalizedString("GivingContextQRCode", comment: ""), subtitle: NSLocalizedString("GiveContextQR", comment: ""))
        case .events:
            cell.name.attributedText = makeAttributedString(title: NSLocalizedString("GivingContextLocation", comment: ""), subtitle: NSLocalizedString("SelectLocationContextLong", comment: ""))
        case .manually:
            cell.name.attributedText = makeAttributedString(title: NSLocalizedString("GivingContextCollectionBagList", comment: ""), subtitle: NSLocalizedString("SelectContextList", comment: ""))
        }
        return cell
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSMutableAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        let boldAttributedString = NSAttributedString(string: title + "\n", attributes: boldAttributes)
        let lightAttributedString = NSAttributedString(string: subtitle, attributes: lightAttributes)
        mutableAttributedString.append(boldAttributedString)
        mutableAttributedString.append(lightAttributedString)
        return mutableAttributedString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContext = contexts[indexPath.row]

        guard let navigationController = self.navigationController else { return }
        
        let sb = UIStoryboard(name:"Main", bundle:nil)
        DispatchQueue.main.async {
            switch selectedContext.type {
            case .collectionDevice:
                if GivtManager.shared.isBluetoothEnabled || TARGET_OS_SIMULATOR != 0 {
                    let vc = sb.instantiateViewController(withIdentifier: "scanView") as! ScanViewController
                    navigationController.show(vc, sender: nil)
                } else {
                    self.showBluetoothMessage()
                }
            case .qr:
                let vc = sb.instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                navigationController.show(vc, sender: nil)
            case .manually:
                let vc = sb.instantiateViewController(withIdentifier: "ManualGivingViewController") as! ManualGivingViewController
                navigationController.show(vc, sender: nil)
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
    
    func showBluetoothMessage() {
        let alert = UIAlertController(
            title: NSLocalizedString("TurnOnBluetooth", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessage", comment: "") + "\n\n" + NSLocalizedString("ExtraBluetoothText", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .default, handler: { action in

        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let selectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedRow, animated: false)
        super.viewDidDisappear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contexts.count
    }
    
    lazy var contexts: [Context] = {
        let collectionDevice = Context(title: NSLocalizedString("GivingContextCollectionBag", comment: ""), subtitle: NSLocalizedString("SelectContextCollect", comment: ""), type: ContextType.collectionDevice, image: #imageLiteral(resourceName: "collectebus"))
        let qr = Context(title: NSLocalizedString("GivingContextQRCode", comment: ""), subtitle: NSLocalizedString("GiveContextQR", comment: ""), type: ContextType.qr, image: #imageLiteral(resourceName: "qrscan"))
        let location = Context(title: NSLocalizedString("GivingContextLocation", comment: ""), subtitle: NSLocalizedString("SelectLocationContextLong", comment: ""), type: ContextType.events, image: #imageLiteral(resourceName: "giveatlocation"))
        let list = Context(title: NSLocalizedString("GivingContextCollectionBagList", comment: ""),subtitle: NSLocalizedString("SelectContextList", comment: ""), type: ContextType.manually, image: #imageLiteral(resourceName: "selectlist"))
        return !GivtManager.shared.hasGivtLocations() ? [collectionDevice, qr, list, location] : [collectionDevice, qr, location, list]
    }()

    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 22
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        giveSubtitle.text = NSLocalizedString("GiveSubtitle", comment: "")
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
        
        title = NSLocalizedString("SelectContext", comment: "")
        contexts.forEach { (context) in
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            contextsStackView.addArrangedSubview(containerView)
            
            let stackView = UIStackView()
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            containerView.addSubview(stackView)
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
            let img = UIImageView(image: context.image)
            img.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(img)
            img.widthAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            label.attributedText = makeAttributedString(title: context.title, subtitle: context.subtitle)
            stackView.addArrangedSubview(label)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.init(rgb: 0x2E2957), NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17)!]
        
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class ContextTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
