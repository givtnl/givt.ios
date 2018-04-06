//
//  ChooseContextViewController.swift
//  ios
//
//  Created by Lennie Stockman on 5/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ChooseContextViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var overlayView: UIView?
    private var selectedContext: Context?
    var completion: ((_ context: ContextType) -> ())?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseContextTableViewCell") as! ChooseContextTableViewCell
        cell.name.text = contexts[indexPath.row].name
        cell.subtext.text = contexts[indexPath.row].explanation
        cell.img.image = contexts[indexPath.row].image
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 0.15)
        var selectedBgView = UIView()
        switch contexts[indexPath.row].type {
        case .collectionDevice:
            selectedBgView.backgroundColor = #colorLiteral(red: 0.09803921569, green: 0.4196078431, blue: 0.7098039216, alpha: 0.3006207192)
        case .qr:
            selectedBgView.backgroundColor = #colorLiteral(red: 0.8439754844, green: 0.2364770174, blue: 0.2862294316, alpha: 1)
        case .manually:
            selectedBgView.backgroundColor = #colorLiteral(red: 1, green: 0.6917269826, blue: 0, alpha: 0.3)
        case .none:
            selectedBgView.backgroundColor = #colorLiteral(red: 0.09803921569, green: 0.4196078431, blue: 0.7098039216, alpha: 0.3006207192)
        }
        cell.selectedBackgroundView = selectedBgView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedContext = contexts[indexPath.row]
        
        
        if completion != nil {
            completion!(selectedContext!.type)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ContextOverlayViewController") as! ContextOverlayViewController
            vc.selectedContext = selectedContext
            self.navigationController?.show(vc, sender: nil)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contexts.count
    }
    
    lazy var contexts: [Context] = {
        var ctxs = [Context]()
        ctxs.append(Context(name: "Collectemiddel", explanation: "Geef met één simpele beweging aan een collectebus, een collectezak, in de dienst of gewoon op straat. Probeer het gewoon!",  type: ContextType.collectionDevice, image: UIImage.init(named: "collectebus")!))
        ctxs.append(Context(name: "QR", explanation: "Wil je de fancy man afhangen? Dit kan! Scan een Givt-code om gewoon te geven.", type: ContextType.qr, image: UIImage.init(named: "qrscan")!))
        ctxs.append(Context(name: "Handmatig", explanation: "Geen zin om je Bluetooth aan te zetten? Niet getreurd, kies handmatig uit de lijst en vervul je behoefte.", type: ContextType.manually, image: UIImage.init(named: "selectlist")!))
        return ctxs
    }()
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        if self.navigationController?.childViewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        NavigationManager.shared.setContextType(type: ContextType.none)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

