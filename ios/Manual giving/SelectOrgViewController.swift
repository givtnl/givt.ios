//
//  SelectOrgViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class SelectOrgViewController: UIViewController {

    @IBOutlet var btnGive: CustomButton!
    @IBOutlet var overigWidth: NSLayoutConstraint!
    @IBOutlet var actiesWidth: NSLayoutConstraint!
    @IBOutlet var stichtingWidth: NSLayoutConstraint!
    @IBOutlet var churchWidth: NSLayoutConstraint!
    @IBOutlet var stackList: UIStackView!
    @IBOutlet var list: UIView!
    var oldView: ManualOrganisationView?
    var selectedTag: Int = 100
    private var lastTag: Int?
    var listToLoad: [[String: String]]!

    @IBOutlet var kerken: UIImageView!
    @IBOutlet var stichtingen: UIImageView!
    @IBOutlet var acties: UIImageView!
    @IBOutlet var straatmzkt: UIImageView!
    
    @IBAction func btnGive(_ sender: Any) {
        GivtService.shared.giveManually(antennaId: (oldView?.organisationId)!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadView(selectedTag)
        
        addTap(kerken)
        addTap(stichtingen)
        addTap(acties)
        //addTap(straatmzkt) //we dont support this atm
        straatmzkt.alpha = 0.3
        
    }
    
    func addTap(_ view: UIView) {
        print("pressed")
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

    func selectOrg(_ sender: UITapGestureRecognizer) {
        if let view = sender.view as? ManualOrganisationView {
            let temp = view.stack.subviews[1] as! UILabel
            print(temp.text)
            oldView?.toggleCheckMark()
            view.toggleCheckMark()
            oldView = view
        }
        print("selected organisation")
    }
    
    func selectType(_ sender: UITapGestureRecognizer) {
        if let view = sender.view as? UIView {
            let tag = view.tag
            loadView(tag)
        }
    }
    
    func loadView(_ tag: Int) {
        if lastTag == tag {
            return
        }
        for view in stackList.arrangedSubviews {
            stackList.removeArrangedSubview(view)
        }
        
        listToLoad = GivtService.shared.orgBeaconList as! [[String: String]]
        var regExp = "c[0-9]|d[be]"
        
        stichtingWidth.constant = 50
        churchWidth.constant = 50
        actiesWidth.constant = 50
        overigWidth.constant = 50
        
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
        listToLoad = listToLoad.filter { ($0["EddyNameSpace"]?.substring(16..<19).matches(regExp))! }
        
        
        // Do any additional setup after loading the view.
        for organisation in listToLoad {
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
            spacer.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8862745098, blue: 0.9058823529, alpha: 1)
            stackList.addArrangedSubview(spacer)
            print(organisation)
            let temp = organisation
            let item = ManualOrganisationView(text: temp["OrgName"]!, orgId: temp["EddyNameSpace"]!)
            stackList.addArrangedSubview(item)
            
            
            
            item.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.addTarget(self, action: #selector(selectOrg))
            item.addGestureRecognizer(tap)
        }
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        spacer.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8862745098, blue: 0.9058823529, alpha: 1)
        stackList.addArrangedSubview(spacer)
        
        self.lastTag = tag
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
