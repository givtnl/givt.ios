//
//  SelectOrgViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class SelectOrgViewController: BaseScanViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    struct PreviousPosition {
        var pos: IndexPath
        var type: Int
        var nameSpace: String
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var typeStackView: UIStackView!
    var lastGivtToOrganisationPosition: Int?
    @IBOutlet var searchBar: UISearchBar!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].length
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentElement = filteredList![sections[indexPath.section].index + indexPath.row]
        let organisation = currentElement.OrgName
        let nameSpace = currentElement.EddyNameSpace
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManualGivingOrganisation", for: indexPath) as! ManualGivingOrganisation
        cell.organisationLabel.text = organisation
        cell.nameSpace = nameSpace
        cell.toggleOff()
        cell.organisationLabel.numberOfLines = 0
        print(nameSpace)
        if let ns = UserDefaults.standard.lastGivtToOrganisation, ns == nameSpace {
            print("we got a match!!!!!")
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            cell.toggleOn()
            prevPos = PreviousPosition(pos: indexPath, type: selectedTag, nameSpace: cell.nameSpace)
            btnGive.isEnabled = true

        }
        
        if let pp = prevPos, pp.type == selectedTag && pp.pos == indexPath  {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            cell.toggleOn()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.title }
    }

    private var prevPos: PreviousPosition?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ManualGivingOrganisation else { return }
        cell.toggleOn()
        prevPos = PreviousPosition(pos: indexPath, type: selectedTag, nameSpace: cell.nameSpace)
        btnGive.isEnabled = true
        UserDefaults.standard.lastGivtToOrganisation = cell.nameSpace
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        prevPos = nil
        if let cell = tableView.cellForRow(at: indexPath) as? ManualGivingOrganisation {
            cell.toggleOff()
        }
        btnGive.isEnabled = false
        UserDefaults.standard.lastGivtToOrganisation = nil
        
    }
    var initial = true
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let visibleRows = tableView.indexPathsForVisibleRows, let lastRow = visibleRows.last?.row, let lastSection = visibleRows.map({$0.section}).last {
            if indexPath.row == lastRow && indexPath.section == lastSection {
                // Finished loading visible rows
                if initial {
                    initial = false
                    //find orgname associated with namespace
                    if let namespace = UserDefaults.standard.lastGivtToOrganisation, let orgName = GivtService.shared.getOrgName(orgNameSpace: namespace) {
                        guard let tableSectionId = sections.index(where: { (sec) -> Bool in
                            return sec.title.uppercased() == String(orgName.first!).uppercased()
                        }) else {
                            return
                        }
                        
                        let sectionIdxOfItem = sections[tableSectionId].index
                        
                        guard let namespaceIdx = filteredList!.index(where: { (o) -> Bool in
                            o.EddyNameSpace == namespace
                        }) else {
                            return
                        }
                        
                        if tableSectionId < tableView.numberOfSections && (namespaceIdx - sectionIdxOfItem) < tableView.numberOfRows(inSection: tableSectionId) {
                            let ip = IndexPath(row: (namespaceIdx - sectionIdxOfItem), section: tableSectionId)
                            tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.top, animated: false)
                        } else {
                            self.log.warning(message: "Tried to scroll to suggestion \(orgName), but the index was out of bounds.")
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
            indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.delegate?.tableView!(tableView, didDeselectRowAt: indexPath)
            return nil
        }
        return indexPath
    }
    
    private var log = LogService.shared
    @IBOutlet var btnGive: CustomButton!
    @IBOutlet var overigWidth: NSLayoutConstraint!
    @IBOutlet var actiesWidth: NSLayoutConstraint!
    @IBOutlet var stichtingWidth: NSLayoutConstraint!
    @IBOutlet var churchWidth: NSLayoutConstraint!
    @IBOutlet var stackList: UIStackView!
    @IBOutlet var list: UIView!
    @IBOutlet var tableView: UITableView!
    
    var selectedView: ManualOrganisationView? {
        didSet {
            btnGive.isEnabled = selectedView != nil
        }
    }
    
    
    var sections : [(index: Int, length :Int, title: String)] = Array()
    private var selectedTag: Int = 100 {
        didSet {
            loadView(selectedTag)
            lastTag = selectedTag
            sections.removeAll()
            
            if filteredList == nil {
                return
            }
            
            if (filteredList!.count > 0) {
                var index = 0
                var string = filteredList![index].OrgName.uppercased()
                var firstCharacter = string.first!
                let names = filteredList!.map { (orgBeacon) -> String in
                    return orgBeacon.OrgName
                }
                for (i, _) in names.enumerated() {
                    let commonPrefix = names[i].commonPrefix(with: names[index], options: .caseInsensitive)
                    if (commonPrefix.count == 0 ) {
                        let title = "\(firstCharacter)"
                        let newSection = (index: index, length: i - index, title: title)
                        sections.append(newSection)
                        index = i
                        string = names[index].uppercased()
                        firstCharacter = string.first!
                    }
                }
                let title = String(firstCharacter)
                let newSection = (index: index, length: names.count - index, title: title)
                sections.append(newSection)
            }
            self.tableView.reloadData()
  
        }
    }
    var passSelectedTag: Int!
    private var lastTag: Int?
    var listToLoad: [OrgBeacon] = {
        var list = GivtService.shared.orgBeaconList
        return list!
    }()
    
    var filteredList: [OrgBeacon]?
    var originalList: [OrgBeacon]?
    
    @IBOutlet var kerken: UIImageView!
    @IBOutlet var stichtingen: UIImageView!
    @IBOutlet var acties: UIImageView!
    
    @IBOutlet var navBar: UINavigationItem!
    @IBAction func btnGive(_ sender: Any) {
        log.info(message: "Giving manually from the list")
        giveManually(antennaID: (prevPos?.nameSpace)!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        
        typeStackView.addArrangedSubview(btnKerken)
        typeStackView.addArrangedSubview(btnStichtingen)
        typeStackView.addArrangedSubview(btnActies)
        
        if passSelectedTag == 100 {
            setActiveType(view: btnStichtingen)
        } else if passSelectedTag == 101 {
            setActiveType(view: btnKerken)
        } else if passSelectedTag == 102 {
            setActiveType(view: btnActies)
        }

        searchBar.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        selectedTag = passSelectedTag
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControlState.normal)
        
        btnGive.isEnabled = false
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionIndexMinimumDisplayRowCount = 20
        tableView.sectionIndexColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        tableView.sectionIndexBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        searchBar.placeholder = NSLocalizedString("SearchHere", comment: "")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtService.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtService.shared.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* selecteren van Kerk/Stichtingen/...-knop langsboven */
    @objc func selectType(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            if view.tag == selectedTag {
                return
            }
            typeStackView.arrangedSubviews.forEach { (view) in
                var replaceView: UIView?
                if view == btnStichtingenSpecial {
                    replaceView = btnStichtingen
                } else if view == btnKerkenSpecial {
                    replaceView = btnKerken
                } else if view == btnActiesSpecial {
                    replaceView = btnActies
                }
                if let idx = typeStackView.arrangedSubviews.index(of: view), replaceView != nil {
                    typeStackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                    typeStackView.insertArrangedSubview(replaceView!, at: idx)
                }
            }
            setActiveType(view: view)
            
            selectedTag = view.tag
        }
    }
    
    func setActiveType(view: UIView) {
        if let positionInStackview = typeStackView.arrangedSubviews.index(of: view) {
            var viewToAdd: UIView?
            switch (view) {
            case btnKerken:
                viewToAdd = btnKerkenSpecial
            case btnStichtingen:
                viewToAdd = btnStichtingenSpecial
            case btnActies:
                viewToAdd = btnActiesSpecial
            default:
                return
            }
            typeStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
            typeStackView.insertArrangedSubview(viewToAdd!, at: positionInStackview)
        }
    }
    
    func createNormalButton(backgroundColor: UIColor, image: UIImage) -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = backgroundColor
        btn.layer.cornerRadius = 3
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        let image = UIImageView(image: image)
        image.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(image)
        image.topAnchor.constraint(equalTo: btn.topAnchor, constant: 8).isActive = true
        image.bottomAnchor.constraint(equalTo: btn.bottomAnchor, constant: -8).isActive = true
        image.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 8).isActive = true
        image.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -8).isActive = true
        
        createShadow(view: btn)
        return btn
    }
    
    func createSpecialButton(tintColor: UIColor, image: UIImage) -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.clear
        btn.layer.shadowOffset = CGSize(width: 0, height: 1)
        btn.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowRadius = 2
        btn.layer.shouldRasterize = true
        btn.layer.rasterizationScale = UIScreen.main.scale
        btn.heightAnchor.constraint(equalToConstant: 75).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
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
        
        let image = UIImageView(image: image)
        image.translatesAutoresizingMaskIntoConstraints = false
        //image.widthAnchor.constraint(equalToConstant: 52).isActive = true
        image.contentMode = .scaleAspectFit
        
        borderView.addSubview(image)
        image.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 8).isActive = true
        image.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -8).isActive = true
        image.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 8).isActive = true
        image.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -8).isActive = true
        return btn
    }
    
    lazy var btnStichtingen: UIButton = {
        let btn = createNormalButton(backgroundColor: #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1), image: #imageLiteral(resourceName: "stichting_white"))
        btn.tag = 100
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        return btn
    }()
    
    lazy var btnStichtingenSpecial: UIButton = {
        let btn = createSpecialButton(tintColor: #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1), image: #imageLiteral(resourceName: "sugg_stichting_white"))
        btn.tag = 100
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        return btn
    }()
    
    lazy var btnKerken: UIButton = {
        let btn = createNormalButton(backgroundColor: #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1), image: #imageLiteral(resourceName: "church_white"))
        btn.tag = 101
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        return btn
    }()
    
    lazy var btnKerkenSpecial: UIButton = {
        let btn = createSpecialButton(tintColor: #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1), image: #imageLiteral(resourceName: "sugg_church_white"))
        btn.tag = 101
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        return btn
    }()
    
    lazy var btnActies: UIButton = {
        let btn = createNormalButton(backgroundColor: #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1), image: #imageLiteral(resourceName: "actions_white"))
        btn.tag = 102
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        return btn
    }()
    
    lazy var btnActiesSpecial: UIButton = {
        let btn = createSpecialButton(tintColor: #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1), image: #imageLiteral(resourceName: "sugg_actions_white"))
        btn.tag = 102
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        return btn
    }()
    
    private func createShadow(view: UIView) {
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 2
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func loadView(_ tag: Int) {
        if lastTag == tag {
            return
        }
    
        var regExp = "c[0-9]|d[be]"
        switch(tag) {
        case 100:
            regExp = "d[0-9]" //stichtingen
            title = NSLocalizedString("Stichtingen", comment: "")
        case 101:
            regExp = "c[0-9]|d[be]" //churches
            title = NSLocalizedString("Churches", comment: "")
        case 102:
            regExp = "a[0-9]" //acties
            title = NSLocalizedString("Acties", comment: "")
        default:
            break
        }
        
        filteredList = listToLoad.filter({ (orgBeacon) -> Bool in
            orgBeacon.EddyNameSpace.substring(16..<19).matches(regExp)
        })
        
        filteredList?.sort(by: { (first, second) -> Bool in
            return first.OrgName < second.OrgName
        })
        
        originalList = filteredList
        
        if let lastOrg = UserDefaults.standard.lastGivtToOrganisation {
            lastGivtToOrganisationPosition = filteredList?.index(where: { (org) -> Bool in
                return org.EddyNameSpace == lastOrg
            })
        }
        
        /* if there has been searchd before: filter list */
        filterList()

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // deselect row otherwise weird things happen in tableview
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.delegate?.tableView!(tableView, didDeselectRowAt: indexPath)
        }
        
        guard !searchText.isEmpty else {
            filteredList = originalList
            selectedTag = Int(selectedTag)
            return
        }
        
        filterList()
        selectedTag = Int(selectedTag)
    }
    
    func filterList() {
        if let searchText = searchBar.text, searchText.count > 0 {
            filteredList = originalList?.filter({ (organisation) -> Bool in
                return organisation.OrgName.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

}
