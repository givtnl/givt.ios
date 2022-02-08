//
//  ExternalSuggestionViewController.swift
//  ios
//
//  Created by Lennie Stockman on 11/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import AudioToolbox
import SafariServices

class ExternalSuggestionViewController: BaseScanViewController {

    var closeAction: () -> () = {}
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let externalSuggestion = ExternalSuggestionView(frame: CGRect.zero)
        externalSuggestion.label.text = "Nicorette {0}"
        self.view.addSubview(externalSuggestion)
        externalSuggestion.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        externalSuggestion.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        externalSuggestion.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        externalSuggestion.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        externalSuggestion.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        externalSuggestion.button.addTarget(self, action: #selector(self.giveAction), for: UIControl.Event.touchUpInside)
        externalSuggestion.button.setTitle(NSLocalizedString("YesPlease", comment: ""), for: UIControl.State.normal)
        
        externalSuggestion.cancelButton.addTarget(self, action: #selector(self.cancel), for: UIControl.Event.touchUpInside)
        externalSuggestion.cancelButton.isUserInteractionEnabled = true
        
        externalSuggestion.image.image = GivtManager.shared.externalIntegration!.logo
        
        setupLabel(label: externalSuggestion.label)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtManager.shared.delegate = self
        GivtManager.shared.externalIntegration!.wasShownAlready = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtManager.shared.delegate = nil
    }

    @objc func giveAction() {
        giveManually(antennaID: GivtManager.shared.externalIntegration!.mediumId)
    }
    
    @objc func cancel(sender: UIButton) {
        GivtManager.shared.externalIntegration = nil
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.closeAction()
            })
        } 
    }
    
    func setupLabel(label: UILabel) {
        let lightAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 17)!,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedString.Key : Any]
        let boldAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 17)!,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedString.Key : Any]
        let mediumId = GivtManager.shared.externalIntegration!.mediumId
        let stopIndex = mediumId.index(of: ".")!
        let namespace = String(mediumId[..<stopIndex])
        let organisation = GivtManager.shared.getOrganisationName(organisationNameSpace: namespace)!
        let with = GivtManager.shared.externalIntegration!.name
        let msg: String
        switch(with){
            case "QR":
                msg = NSLocalizedString("QRScannedOutOfApp", comment: "").replacingOccurrences(of:"{0}", with: organisation)
                break
            case "normal":
                msg = NSLocalizedString("GiveOutOfApp", comment: "").replacingOccurrences(of:"{0}", with: organisation)
                break
            default:
                msg = NSLocalizedString("ExternalSuggestionLabel", comment: "").replacingOccurrences(of: "{0}", with: GivtManager.shared.externalIntegration!.name).replacingOccurrences(of:"{1}", with: organisation)
                break
        }
        
        let rangeOfSubstring = (msg as NSString).range(of: organisation)
        let attributedString = NSMutableAttributedString(string: msg, attributes: lightAttributes)
        attributedString.setAttributes(boldAttributes, range: rangeOfSubstring)
        label.attributedText = attributedString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        if let _ = URL.absoluteString.index(of: "cloud.givtapp.net") {
            DispatchQueue.main.async {
                /* TODO: how to reset amountVC ?? */
                self.safariViewController?.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .GivtAmountsShouldReset, object: self)
            }
        }
    }
}
