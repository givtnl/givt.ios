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
    
    var lastGivtToOrganisationPosition: Int?
    @IBOutlet var searchBar: UISearchBar!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].length
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let organisation = names[sections[indexPath.section].index + indexPath.row]
        let nameSpace = nameSpaces[sections[indexPath.section].index + indexPath.row]
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
                        
                        guard let namespaceIdx = nameSpaces.index(where: { (ns) -> Bool in
                            return ns == namespace
                        }) else {
                            return
                        }
                    
                        let ip = IndexPath(row: (namespaceIdx - sectionIdxOfItem), section: tableSectionId)
                        tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.top, animated: false)
  
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
    var names: [String] = [String]()
    var nameSpaces: [String] = [String]()
    private var selectedTag: Int = 100 {
        didSet {
            loadView(selectedTag)
            lastTag = selectedTag
            sections.removeAll()
            names.removeAll()
            nameSpaces.removeAll()
            for org in filteredList! {
                names.append(org["OrgName"]!)
                nameSpaces.append(org["EddyNameSpace"]!)
            }
            
            if (names.count > 0) {
                var index = 0
                var string = names[index].uppercased()
                var firstCharacter = string[string.startIndex]
                for (i, name) in names.enumerated() {
                    let commonPrefix = names[i].commonPrefix(with: names[index], options: .caseInsensitive)
                    if (commonPrefix.count == 0 ) {
                        let title = "\(firstCharacter)"
                        let newSection = (index: index, length: i - index, title: title)
                        sections.append(newSection)
                        index = i
                        string = names[index].uppercased()
                        firstCharacter = string[string.startIndex]
                    }
                }
                let title = "\(firstCharacter)"
                let newSection = (index: index, length: names.count - index, title: title)
                sections.append(newSection)
            }
            self.tableView.reloadData()
  
        }
    }
    var passSelectedTag: Int!
    private var lastTag: Int?
    var listToLoad: [[String: String]] = {
        var list = GivtService.shared.orgBeaconList as! [[String: String]]
        print(list)
        return list
    }()
    
    var filteredList: [[String: String]]?
    var originalList: [[String: String]]?
    
    @IBOutlet var kerken: UIImageView!
    @IBOutlet var stichtingen: UIImageView!
    @IBOutlet var acties: UIImageView!
    @IBOutlet var straatmzkt: UIImageView!
    
    @IBOutlet var navBar: UINavigationItem!
    @IBAction func btnGive(_ sender: Any) {
        log.info(message: "Giving manually from the list")
        GivtService.shared.giveManually(antennaId: (prevPos?.nameSpace)!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        selectedTag = passSelectedTag
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControlState.normal)
        addTap(kerken, 101)
        addTap(stichtingen, 100)
        addTap(acties, 102)
        //addTap(straatmzkt) //we dont support this atm
        straatmzkt.alpha = 0.3
        
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
    
    func addTap(_ view: UIView, _ tag: Int) {
        view.isUserInteractionEnabled = true
        view.tag = tag
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* selecteren van Kerk/Stichtingen/...-knop langsboven */
    @objc func selectType(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            selectedTag = view.tag
        }
    }
    
    func loadView(_ tag: Int) {
        if lastTag == tag {
            return
        }

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
            title = NSLocalizedString("Stichtingen", comment: "")
        case 101:
            regExp = "c[0-9]|d[be]" //churches
            churchWidth.constant = 80
            title = NSLocalizedString("Churches", comment: "")
        case 102:
            regExp = "a[0-9]" //acties
            actiesWidth.constant = 80
            title = NSLocalizedString("Acties", comment: "")
            //case 103: // overig
        //we have no other beacons :c
        default:
            break
        }
        
        filteredList = listToLoad.filter { ($0["EddyNameSpace"]?.substring(16..<19).matches(regExp))! }
        originalList = filteredList
        
        if let lastOrg = UserDefaults.standard.lastGivtToOrganisation {
            lastGivtToOrganisationPosition = filteredList?.index(where: { (org) -> Bool in
                return org["EddyNameSpace"] == lastOrg
            })
        }
        
        /* if there has been searchd before: filter list */
        filterList()

    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
                if let org = organisation["OrgName"] {
                    return org.lowercased().contains(searchText.lowercased())
                } else {
                    return false
                }
            })
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

}
