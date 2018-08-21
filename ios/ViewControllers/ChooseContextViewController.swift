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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseContextTableViewCell") as! ChooseContextTableViewCell
        cell.name.text = contexts[indexPath.row].name
        //cell.subtext.text = contexts[indexPath.row].explanation
        cell.img.image = contexts[indexPath.row].image
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.contextType = contexts[indexPath.row].type
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContext = contexts[indexPath.row]

        guard let navigationController = self.navigationController else { return }
        
        let sb = UIStoryboard(name:"Main", bundle:nil)
        DispatchQueue.main.async {
            switch selectedContext.type {
            case .collectionDevice:
                if GivtService.shared.isBluetoothEnabled || TARGET_OS_SIMULATOR != 0 {
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
                if self.givtLocations.count == 0 {
                    let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
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
        var ctxs = [Context]()
        ctxs.append(Context(name: NSLocalizedString("SelectContextCollect", comment: ""),  type: ContextType.collectionDevice, image: #imageLiteral(resourceName: "collectebus")))
        ctxs.append(Context(name: NSLocalizedString("GiveContextQR", comment: ""), type: ContextType.qr, image: #imageLiteral(resourceName: "qrscan")))
        ctxs.append(Context(name: NSLocalizedString("SelectLocationContextLong", comment: ""), type: ContextType.events, image: #imageLiteral(resourceName: "giveatlocation")))
        ctxs.append(Context(name: NSLocalizedString("SelectContextList", comment: ""), type: ContextType.manually, image: #imageLiteral(resourceName: "selectlist")))
        return ctxs
    }()
    
    private var givtLocations = [GivtLocation]()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        givtLocations = GivtService.shared.getGivtLocations()
        
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

