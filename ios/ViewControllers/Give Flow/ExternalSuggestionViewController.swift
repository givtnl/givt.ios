//
//  ExternalSuggestionViewController.swift
//  ios
//
//  Created by Lennie Stockman on 11/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ExternalSuggestionViewController: BaseScanViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.statusBarStyle = .lightContent
        // Do any additional setup after loading the view.
        let externalSuggestion = ExternalSuggestionView(frame: CGRect.zero)
        externalSuggestion.label.text = "Nicorette {0}"
        self.view.addSubview(externalSuggestion)
        externalSuggestion.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        externalSuggestion.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        externalSuggestion.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        externalSuggestion.button.addTarget(self, action: #selector(self.giveAction), for: UIControlEvents.touchUpInside)
        externalSuggestion.button.setTitle(NSLocalizedString("YesPlease", comment: ""), for: UIControlState.normal)
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("ChooseHowIGive", comment: ""), attributes: [NSAttributedStringKey.underlineStyle : true])
        externalSuggestion.cancelButton.setAttributedTitle(attributedString, for: UIControlState.normal)
        setupLabel(label: externalSuggestion.label)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtService.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtService.shared.delegate = nil
    }
    
    @objc func giveAction() {
        giveManually(antennaID: GivtService.shared.customReturnAppSchemeMediumId!)
    }
    
    @objc func cancel() {
        
    }
    
    func setupLabel(label: UILabel) {
        let lightAttributes = [
            NSAttributedStringKey.font: UIFont(name: "Avenir-Light", size: 17)!,
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedStringKey : Any]
        let boldAttributes = [
            NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17)!,
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedStringKey : Any]
        guard let mediumId = GivtService.shared.customReturnAppSchemeMediumId else {
            return
        }
        let stopIndex = mediumId.index(of: ".")!
        let namespace = String(mediumId[..<stopIndex])
        let organisation = GivtService.shared.getOrganisationName(organisationNameSpace: namespace)!
        let msg = NSLocalizedString("ExternalSuggestionLabel", comment: "").replacingOccurrences(of:"{0}", with: organisation)
        let rangeOfSubstring = (msg as NSString).range(of: organisation)
        let attributedString = NSMutableAttributedString(string: msg, attributes: lightAttributes)
        attributedString.setAttributes(boldAttributes, range: rangeOfSubstring)
        label.attributedText = attributedString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
