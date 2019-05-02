//
//  ManualGivingViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import AppCenterAnalytics

class ManualGivingViewController: BaseScanViewController, UIGestureRecognizerDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var titleText: UILabel!
    private var log = LogService.shared

    var cameFromScan: Bool = false
    enum Choice: String {
        case foundations
        case churches
        case actions
        case other
    }
    
    @IBOutlet var navBar: UINavigationItem!
    var pickedChoice: Choice!
    private var namespace: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        titleText.text = NSLocalizedString("ChooseWhoYouWantToGiveTo", comment: "")
        renderButtons()
    }
    
    private func fillSuggestion() -> UIView? {
        if let bb = GivtManager.shared.bestBeacon {
            namespace = bb.namespace
        } else if let savedNamespace = UserDefaults.standard.lastGivtToOrganisationNamespace {
            namespace = savedNamespace
        }
        
        guard let _ = GivtManager.shared.orgBeaconList?.first(where: { $0.EddyNameSpace == namespace }) else { return nil }
        
        guard let namespace = namespace else { return nil }
        
        guard let orgName = GivtManager.shared.getOrganisationName(organisationNameSpace: namespace) else { return nil }
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(giveSuggestion))
        
        var c: UIColor?
        var i: UIImage?
        let type  = namespace.substring(16..<19)
        if type.matches("c[0-9]|d[be]") { //is a chrch
            c = #colorLiteral(red: 0.09952672571, green: 0.41830042, blue: 0.7092369199, alpha: 1)
            i = #imageLiteral(resourceName: "sugg_church_white")
        } else if type.matches("d[0-9]") { //stichitng
            c = #colorLiteral(red: 1, green: 0.6917269826, blue: 0, alpha: 1)
            i = #imageLiteral(resourceName: "sugg_stichting_white")
        } else if type.matches("a[0-9]") { //acties
            c = #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1)
            i = #imageLiteral(resourceName: "sugg_actions_white")
        } else if type.matches("b[0-9]") {
            c = #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1)
            i = #imageLiteral(resourceName: "artist_white")
        }

        guard let tintColor = c, let image = i else { return nil }
        
        let suggestion = createSuggestion(suggestionTitle: NSLocalizedString("Suggestie", comment: ""), text: orgName, image: image, backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), tintColor: tintColor)
        suggestion.addGestureRecognizer(tap)
        return suggestion
    }
    
    private func createShadow(view: UIView) {
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 2
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func createButton(text: String, image: UIImage, backgroundColor: UIColor, useShadow: Bool) -> UIButton {
        let btn = UIButton()
        btn.accessibilityLabel = text
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 3
        btn.backgroundColor = backgroundColor
        if useShadow {
            createShadow(view: btn)
        }
        
        btn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 25
        btn.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: btn.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: btn.bottomAnchor).isActive = true
        
        let image = UIImageView(image: image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Heavy", size: 18)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        let arrow = UIImageView(image: #imageLiteral(resourceName: "smallwhitearrow"))
        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.widthAnchor.constraint(equalToConstant: 6).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(arrow)
        return btn
    }
    
    private func createSuggestion(suggestionTitle: String, text: String, image: UIImage, backgroundColor: UIColor, tintColor: UIColor) -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.clear
        btn.layer.shadowOffset = CGSize(width: 0, height: 1)
        btn.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowRadius = 2
        btn.layer.shouldRasterize = true
        btn.layer.rasterizationScale = UIScreen.main.scale
        btn.accessibilityLabel = suggestionTitle + " " + text
        
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = backgroundColor
        borderView.frame = btn.bounds
        borderView.layer.cornerRadius = 3
        borderView.layer.borderColor = tintColor.cgColor
        borderView.layer.borderWidth = 1
        borderView.layer.masksToBounds = true
        btn.addSubview(borderView)
        borderView.topAnchor.constraint(equalTo: btn.topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: btn.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: btn.trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: btn.bottomAnchor).isActive = true
        
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        bar.backgroundColor = tintColor
        borderView.addSubview(bar)
        bar.bottomAnchor.constraint(equalTo: borderView.bottomAnchor).isActive = true
        bar.leadingAnchor.constraint(equalTo: borderView.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: borderView.trailingAnchor).isActive = true
        
        let title = UILabel()
        title.text = suggestionTitle
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .left
        title.font = UIFont(name: "Avenir-Light", size: 20)
        title.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        borderView.addSubview(title)
        title.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 10).isActive = true
        title.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 97).isActive = true
        title.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: 10).isActive = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 25
        borderView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8).isActive = true
        stackView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -13).isActive = true
        
        let image = UIImageView(image: image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 52).isActive = true
        image.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        
        let arrow = UIImageView(image: #imageLiteral(resourceName: "smallpurplearrow"))
        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.widthAnchor.constraint(equalToConstant: 6).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 10).isActive = true
        arrow.tintColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(arrow)
        return btn
    }

    func renderButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        
        contentView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20).isActive = true
        
        let stichtingen = createButton(text: NSLocalizedString("Stichtingen", comment: ""), image: #imageLiteral(resourceName: "stichting_white"), backgroundColor: #colorLiteral(red: 0.9568627451, green: 0.7490196078, blue: 0.3882352941, alpha: 1), useShadow: true)
        let churches = createButton(text: NSLocalizedString("Churches", comment: ""), image: #imageLiteral(resourceName: "church_white"), backgroundColor: #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1), useShadow: true)
        let actions = createButton(text: NSLocalizedString("Acties", comment: ""), image: #imageLiteral(resourceName: "actions_white"), backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.4392156863, blue: 0.3411764706, alpha: 1), useShadow: true)
        let artiest = createButton(text: NSLocalizedString("Artists", comment: ""), image: #imageLiteral(resourceName: "artist"), backgroundColor: #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1), useShadow: true)
        
        stichtingen.tag = 100
        churches.tag = 101
        actions.tag = 102
        artiest.tag = 103
        
        addAction(stichtingen)
        addAction(churches)
        addAction(actions)
        addAction(artiest)
        
        if let suggestief = fillSuggestion() {
            stackView.addArrangedSubview(suggestief)
        }
        
        stackView.addArrangedSubview(churches)
        stackView.addArrangedSubview(stichtingen)
        stackView.addArrangedSubview(actions)
        stackView.addArrangedSubview(artiest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtManager.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtManager.shared.delegate = nil
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disableButtons = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_third"))
        navigationItem.accessibilityLabel = NSLocalizedString("ProgressBarStepThree", comment: "")
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
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
    
    @objc func giveSuggestion() {
        if(cameFromScan){
            MSAnalytics.trackEvent("User came from ScanPage and pressed Suggestion")
        }
        if let beaconId = namespace {
            log.info(message: "Gave to the suggestion")
            if let idx = beaconId.index(of: ".") {
                let namespace = beaconId[..<idx]
                giveManually(antennaID: String(namespace))
            } else {
                giveManually(antennaID: beaconId)
            }
        }
    }
}


