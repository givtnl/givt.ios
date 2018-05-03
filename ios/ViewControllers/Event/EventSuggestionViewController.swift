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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 40.0
        
        self.view.layoutIfNeeded()
        self.btnGive.text = "Ja, graag!"
        self.btnGive.layer.cornerRadius = 15
        self.btnGive.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(give))
        btnGive.isUserInteractionEnabled = true
        btnGive.addGestureRecognizer(tap)
        
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont(name: "Avenir-Heavy", size: 48)
        label.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi / 36))
        label.text = String(Date().getDay())
        eventImage.addSubview(label)
        label.topAnchor.constraint(equalTo: eventImage.topAnchor, constant: 22).isActive = true
        label.leadingAnchor.constraint(equalTo: eventImage.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: eventImage.trailingAnchor, constant: 0).isActive = true
        
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
        
        
        let msg = "Hey! Je staat op een evenement waar Givt ondersteund word. Wil jij toevallig geven aan Zwolle Unlimited?"
        let rangeOfSubstring = (msg as! NSString).range(of: "Zwolle Unlimited")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
