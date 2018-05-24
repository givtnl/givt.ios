//
//  EventSuggestionViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/05/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class EventSuggestionViewController: UIViewController {

    @IBOutlet var message: UILabel!
    @IBOutlet var btnGive: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var eventImage: UIImageView!
    var onClose: () -> () = {}
    var onSuccess: () -> () = {}
    var organisation: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 40.0
        
        self.view.layoutIfNeeded()
        self.btnGive.text = NSLocalizedString("YesPlease", comment: "")
        self.btnGive.layer.cornerRadius = 15
        self.btnGive.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(give))
        btnGive.isUserInteractionEnabled = true
        btnGive.addGestureRecognizer(tap)
        
        let mutableAttributedString = NSMutableAttributedString()
        
        let lightAttributes = [
            NSAttributedStringKey.font: UIFont(name: "Avenir-Light", size: 17)!,
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedStringKey : Any]
        let boldAttributes = [
            NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17)!,
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedStringKey : Any]
        
        let boldAttributedString = NSAttributedString(string: UserDefaults.standard.userExt!.email, attributes: boldAttributes)
        mutableAttributedString.append(NSAttributedString(string: NSLocalizedString("SendOverViewTo", comment: "") + " "))
        mutableAttributedString.append(boldAttributedString)
        
        
        let msg = NSLocalizedString("GivtEventText", comment: "").replacingOccurrences(of:"{0}", with: organisation)
        let rangeOfSubstring = (msg as NSString).range(of: organisation)
        let attributedString = NSMutableAttributedString(string: msg, attributes: lightAttributes)
        attributedString.setAttributes(boldAttributes, range: rangeOfSubstring)
        message.attributedText = attributedString
        
    }
    
    @objc func give() {
        self.dismiss(animated: true, completion: {
            self.onSuccess()
        })
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true) {
            self.onClose()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.view == self.view {
            DispatchQueue.main.async {
                self.close(self)
            }
        }
    }

}
