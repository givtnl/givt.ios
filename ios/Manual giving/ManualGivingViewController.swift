//
//  ManualGivingViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class ManualGivingViewController: UIViewController {

    @IBOutlet var btnQR: UIView!
    @IBOutlet var btnOverig: UIView!
    @IBOutlet var btnActies: UIView!
    @IBOutlet var btnKerken: UIView!
    @IBOutlet var btnStichtingen: UIView!
    enum Choice: String {
        case foundations
        case churches
        case actions
        case other
    }
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var qr: UILabel!
    @IBOutlet var overig: UILabel!
    @IBOutlet var acties: UILabel!
    @IBOutlet var kerken: UILabel!
    @IBOutlet var stichtingen: UILabel!
    @IBOutlet var navBar: UINavigationItem!
    var pickedChoice: Choice!
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
        
        print(stackView.spacing)
    }

    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func choose(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            switch tag {
            case 100, 101, 102, 103:
                let vc = storyboard?.instantiateViewController(withIdentifier: "SelectOrgViewController") as! SelectOrgViewController
                vc.selectedTag = tag
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
