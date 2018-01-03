//
//  SelectOrgViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class SelectOrgViewController: BaseScanViewController {
    private var log = LogService.shared
    @IBOutlet var btnGive: CustomButton!
    @IBOutlet var overigWidth: NSLayoutConstraint!
    @IBOutlet var actiesWidth: NSLayoutConstraint!
    @IBOutlet var stichtingWidth: NSLayoutConstraint!
    @IBOutlet var churchWidth: NSLayoutConstraint!
    @IBOutlet var stackList: UIStackView!
    @IBOutlet var list: UIView!
    var selectedView: ManualOrganisationView? {
        didSet {
            btnGive.isEnabled = selectedView != nil
        }
    }
    var selectedTag: Int = 100
    private var lastTag: Int?
    var listToLoad: [[String: String]]!

    @IBOutlet var kerken: UIImageView!
    @IBOutlet var stichtingen: UIImageView!
    @IBOutlet var acties: UIImageView!
    @IBOutlet var straatmzkt: UIImageView!
    
    @IBOutlet var navBar: UINavigationItem!
    @IBAction func btnGive(_ sender: Any) {
        log.info(message: "Giving manually from the list")
        GivtService.shared.giveManually(antennaId: (selectedView?.organisationId)!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadView(selectedTag)
        navBar.title = NSLocalizedString("GiveDifferently", comment: "")
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControlState.normal)
        addTap(kerken)
        addTap(stichtingen)
        addTap(acties)
        //addTap(straatmzkt) //we dont support this atm
        straatmzkt.alpha = 0.3
        
        btnGive.isEnabled = false
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtService.shared.onGivtProcessed = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtService.shared.onGivtProcessed = nil
    }
    
    func addTap(_ view: UIView) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* selecteren van een organisatie in de lijst */
    @objc func selectOrg(_ sender: UITapGestureRecognizer) {
        if let view = sender.view as? ManualOrganisationView {
            selectedView?.toggleCheckMark() //vorige geselectede optie deselecteren
            if selectedView == view {
                selectedView = nil
                return
            }
            view.toggleCheckMark()
            selectedView = view
        }
    }
    
    /* selecteren van Kerk/Stichtingen/...-knop langsboven */
    @objc func selectType(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            loadView(view.tag)
        }
    }
    
    
    /* creates a spacer view */
    fileprivate func renderSpacer() {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        spacer.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8862745098, blue: 0.9058823529, alpha: 1)
        stackList.addArrangedSubview(spacer)
    }
    
    func loadView(_ tag: Int) {
        if lastTag == tag {
            return
        }

        /* clear list */
        for view in stackList.arrangedSubviews {
            stackList.removeArrangedSubview(view)
            view.removeFromSuperview() /* important! */
        }
        
        listToLoad = GivtService.shared.orgBeaconList as! [[String: String]]
        
        /* reset all widths */
        stichtingWidth.constant = 50
        churchWidth.constant = 50
        actiesWidth.constant = 50
        overigWidth.constant = 50
        
        var regExp = "c[0-9]|d[be]"
        switch(tag) {
        case 100:
            regExp = "d[0-9]" //stichtingen
            stichtingWidth.constant = 80
        case 101:
            regExp = "c[0-9]|d[be]" //churches
            churchWidth.constant = 80
        case 102:
            regExp = "a[0-9]" //acties
            actiesWidth.constant = 80
            //case 103: // overig
        //we have no other beacons :c
        default:
            break
        }
        self.view.layoutIfNeeded()
        
        /* filter list based on regExp */
        listToLoad = listToLoad.filter { ($0["EddyNameSpace"]?.substring(16..<19).matches(regExp))! }

        for organisation in listToLoad {
            renderSpacer()
            let temp = organisation
            let item = ManualOrganisationView(text: temp["OrgName"]!, orgId: temp["EddyNameSpace"]!)
            stackList.addArrangedSubview(item)
            
            /* Going back to previous type will add the check when it was previously selected */
            if selectedView?.organisationId == item.organisationId && selectedView?.label.text == item.label.text {
                item.toggleCheckMark()
                selectedView = item
            }

            item.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.addTarget(self, action: #selector(selectOrg))
            item.addGestureRecognizer(tap)
        }
        renderSpacer()
        
        self.lastTag = tag
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
