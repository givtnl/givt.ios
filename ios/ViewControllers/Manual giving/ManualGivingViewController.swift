//
//  ManualGivingViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class ManualGivingViewController: BaseScanViewController, UIGestureRecognizerDelegate {
    private var log = LogService.shared
    @IBOutlet var organisationSuggestion: UILabel!
    @IBOutlet var containerHeight: NSLayoutConstraint!
    @IBOutlet var suggestion: UIView!
    @IBOutlet var btnQR: UIView!
    @IBOutlet var btnOverig: UIView!
    @IBOutlet var btnActies: UIView!
    @IBOutlet var btnKerken: UIView!
    @IBOutlet var btnStichtingen: UIView!
    @IBOutlet var suggestionImage: UIImageView!
    enum Choice: String {
        case foundations
        case churches
        case actions
        case other
    }
    
    @IBOutlet var suggestionText: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var qr: UILabel!
    @IBOutlet var overig: UILabel!
    @IBOutlet var acties: UILabel!
    @IBOutlet var kerken: UILabel!
    @IBOutlet var stichtingen: UILabel!
    @IBOutlet var navBar: UINavigationItem!
    var pickedChoice: Choice!
    private var beaconId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = NSLocalizedString("GiveDifferently", comment: "")
        stichtingen.text = NSLocalizedString("Stichtingen", comment: "")
        kerken.text = NSLocalizedString("Churches", comment: "")
        acties.text = NSLocalizedString("Acties", comment: "")
        overig.text = NSLocalizedString("Overig", comment: "")
        qr.text = NSLocalizedString("GiveDifferentScan", comment: "")
        
        addAction(btnKerken)
        addAction(btnStichtingen)
        addAction(btnActies)
        //addAction(btnOverig) //we don't support this atm
        addAction(btnQR)
        
        btnStichtingen.tag = 100
        btnKerken.tag = 101
        btnActies.tag = 102
        btnOverig.tag = 103
        btnOverig.alpha = 0.3
        btnQR.tag = 104

        let lastOrg = GivtService.shared.lastGivtOrg
        if let beaconId = GivtService.shared.getBestBeacon.beaconId, !lastOrg.isEmpty() {
            suggestionText.text = NSLocalizedString("Suggestie", comment: "")
            self.beaconId = beaconId

            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(giveManually))
            suggestion.addGestureRecognizer(tap)
            suggestion.layer.cornerRadius = 3
            
            /* filter list based on regExp */
            var bg: UIColor = #colorLiteral(red: 0.09952672571, green: 0.41830042, blue: 0.7092369199, alpha: 0.2)
            let type  = beaconId.substring(16..<19)
            if type.matches("c[0-9]|d[be]") { //is a chrch
                bg = #colorLiteral(red: 0.09952672571, green: 0.41830042, blue: 0.7092369199, alpha: 0.2)
                suggestionImage.image = #imageLiteral(resourceName: "kerken")
            } else if type.matches("d[0-9]") { //stichitng
                bg = #colorLiteral(red: 0.9652975202, green: 0.7471453547, blue: 0.3372098804, alpha: 0.2)
                suggestionImage.image = #imageLiteral(resourceName: "stichtingen")
            } else if type.matches("a[0-9]") { //acties
                bg = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 0.2)
                suggestionImage.image = #imageLiteral(resourceName: "acties")
            }
            /* when we have the "other" option, don't forget to add regexp !*/
            
            suggestion.backgroundColor = bg
            organisationSuggestion.text = lastOrg
            suggestion.isHidden = false
        } else {
            suggestion.removeFromSuperview()
            suggestion.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtService.shared.onGivtProcessed = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtService.shared.onGivtProcessed = nil
    }

    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disableButtons = false
    }

    private var disableButtons = false
    @objc func choose(_ sender: UITapGestureRecognizer) {
        if disableButtons {
            return
        }
        disableButtons = true
        if let tag = sender.view?.tag {
            switch tag {
            case 100, 101, 102, 103:
                let vc = storyboard?.instantiateViewController(withIdentifier: "SelectOrgViewController") as! SelectOrgViewController
                vc.passSelectedTag = tag
                self.show(vc, sender: nil)
            case 104:
                print("qr")
                let vc = storyboard?.instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                self.show(vc, sender: nil)
            default:
                break
            }
        }
    }
    
    func addAction(_ view: UIView) {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(choose(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func giveManually() {
        if let beaconId = self.beaconId {
            log.info(message: "Gave to the suggestion")
            GivtService.shared.give(antennaID: beaconId)
        }
    }
}
