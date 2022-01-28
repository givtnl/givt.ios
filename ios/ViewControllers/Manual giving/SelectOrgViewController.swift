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
    
    var cameFromScan: Bool = false
    var lastGivtToOrganisationPosition: Int?
    var initial = true
    var scrollTo = true
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var typeStackView: UIStackView!
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

        if initial, let ns = getPreselectedOrganisation(), ns == nameSpace {
            initial = false
            prevPos = PreviousPosition(pos: indexPath, type: selectedTag, nameSpace: nameSpace)
        }
        
        if let pp = prevPos, (pp.type == selectedTag || pp.type == 0 || selectedTag == 0) && pp.nameSpace == nameSpace  {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
            cell.toggleOn()
            btnGive.isEnabled = true
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
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        prevPos = nil
        if let cell = tableView.cellForRow(at: indexPath) as? ManualGivingOrganisation {
            cell.toggleOff()
        }
        btnGive.isEnabled = false
    }
    

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let visibleRows = tableView.indexPathsForVisibleRows, let lastRow = visibleRows.last?.row, let lastSection = visibleRows.map({$0.section}).last {
            if indexPath.row == lastRow, indexPath.section == lastSection, scrollTo {
                scrollTo = false
                // Finished loading visible rows
                var namespace: String?
                
                if initial {
                    namespace = getPreselectedOrganisation()
                }
                else if let pp = prevPos {
                    namespace = pp.nameSpace
                }
                
                //find orgname associated with namespace
                if let namespace = namespace, let orgName = GivtManager.shared.getOrganisationName(organisationNameSpace: namespace) {
                    guard let tableSectionId = sections.firstIndex(where: { (sec) -> Bool in
                        return sec.title.uppercased() == String(orgName.first!).uppercased()
                    }) else {
                        return
                    }
                    
                    let sectionIdxOfItem = sections[tableSectionId].index
                    
                    guard let namespaceIdx = filteredList!.firstIndex(where: { (o) -> Bool in
                        o.EddyNameSpace == namespace
                    }) else {
                        return
                    }
                    
                    if tableSectionId < tableView.numberOfSections && (namespaceIdx - sectionIdxOfItem) < tableView.numberOfRows(inSection: tableSectionId) {
                        let ip = IndexPath(row: (namespaceIdx - sectionIdxOfItem), section: tableSectionId)
                        tableView.scrollToRow(at: ip, at: UITableView.ScrollPosition.top, animated: false)
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
    @IBOutlet var artiestWidth: NSLayoutConstraint!
    
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
        }
    }
    
    private var lastTag: Int?
    var listToLoad: [OrgBeacon] = {
        var list = GivtManager.shared.orgBeaconList
        return list ?? [OrgBeacon]()
    }()
    
    var filteredList: [OrgBeacon]?
    var originalList: [OrgBeacon]?
    
    @IBOutlet var kerken: UIImageView!
    @IBOutlet var stichtingen: UIImageView!
    @IBOutlet var acties: UIImageView!
    @IBOutlet var artiest: UIImageView!
    @IBOutlet var navBar: UINavigationItem!
    
    @IBAction func btnGive(_ sender: Any) {
        log.info(message: "Giving manually from the list")
        giveManually(antennaID: (prevPos?.nameSpace)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        btnGive.accessibilityLabel = NSLocalizedString("Give", comment: "")
        
        typeStackView.addArrangedSubview(btnKerken)
        typeStackView.addArrangedSubview(btnStichtingen)
        typeStackView.addArrangedSubview(btnActies)
        typeStackView.addArrangedSubview(btnArtiest)
        
        searchBar.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControl.State.normal)
        
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
        searchBar.accessibilityLabel = NSLocalizedString("SearchHere", comment: "")
        
        selectedTag = 0
        loadView(0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtManager.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtManager.shared.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
    
    /* selecteren van Kerk/Stichtingen/...-knop langsboven */
    @objc func selectType(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            scrollTo = true
            if view.tag == selectedTag {
                unsetActiveType(view: view)
                selectedTag = 0
            } else {
                typeStackView.arrangedSubviews.forEach { (v) in
                    var replaceView: UIView?
                    if v == btnStichtingenSpecial {
                        replaceView = btnStichtingen
                    } else if v == btnKerkenSpecial {
                        replaceView = btnKerken
                    } else if v == btnActiesSpecial {
                        replaceView = btnActies
                    } else if v == btnArtiestSpecial {
                        replaceView = btnArtiest
                    }
                    
                    if let idx = typeStackView.arrangedSubviews.firstIndex(of: v), replaceView != nil {
                        typeStackView.removeArrangedSubview(v)
                        v.removeFromSuperview()
                        typeStackView.insertArrangedSubview(replaceView!, at: idx)
                    }
                }
                
                setActiveType(view: view)
                selectedTag = view.tag
            }
        }
    }
    
    func setActiveType(view: UIView) {
        if let positionInStackview = typeStackView.arrangedSubviews.firstIndex(of: view) {
            var viewToAdd: UIView?
            var orgType = MediumHelper.OrganisationType.invalid
            
            switch (view) {
            case btnKerken:
                viewToAdd = btnKerkenSpecial
                orgType = .church
            case btnStichtingen:
                viewToAdd = btnStichtingenSpecial
                orgType = .charity
            case btnActies:
                viewToAdd = btnActiesSpecial
                orgType = .campaign
            case btnArtiest:
                viewToAdd = btnArtiestSpecial
                orgType = .artist
            default:
                return
            }
            typeStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
            typeStackView.insertArrangedSubview(viewToAdd!, at: positionInStackview)
            
            if let pp = prevPos, MediumHelper.namespaceToOrganisationType(namespace: pp.nameSpace) != orgType {
                /* Disable give button because selected organisation is not in view anymore */
                btnGive.isEnabled = false
            }
        }
    }
    
    func unsetActiveType(view: UIView) {
        if let positionInStackview = typeStackView.arrangedSubviews.firstIndex(of: view) {
            var viewToAdd: UIView?
            switch (view) {
            case btnKerkenSpecial:
                viewToAdd = btnKerken
            case btnStichtingenSpecial:
                viewToAdd = btnStichtingen
            case btnActiesSpecial:
                viewToAdd = btnActies
            case btnArtiestSpecial:
                viewToAdd = btnArtiest
            default:
                return
            }
            typeStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
            typeStackView.insertArrangedSubview(viewToAdd!, at: positionInStackview)

            if let _ = prevPos {
                /* Enable give button because selected organisation is in view again */
                btnGive.isEnabled = true
            }
        }

    }
    
    func createNormalButton(backgroundColor: UIColor, image: UIImage, labelText: String) -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = backgroundColor
        btn.layer.cornerRadius = 3
        btn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        let image = UIImageView(image: image)
        image.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(image)
        image.contentMode = .scaleAspectFit
        image.topAnchor.constraint(equalTo: btn.topAnchor, constant: 4).isActive = true
        image.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont(name: "Avenir Heavy", size: 11)
        label.text = labelText
        btn.addSubview(label)
        label.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -4).isActive = true
        label.bottomAnchor.constraint(equalTo: btn.bottomAnchor, constant: -4).isActive = true
        
        createShadow(view: btn)
        return btn
    }
    
    func createSpecialButton(tintColor: UIColor, image: UIImage, labelText: String) -> UIButton {
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
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir Heavy", size: 12)
        label.text = labelText
        label.textColor = tintColor
        borderView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -4).isActive = true
        
        let image = UIImageView(image: image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        borderView.addSubview(image)
        image.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 4).isActive = true
        image.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -4).isActive = true

        return btn
    }
    
    lazy var btnStichtingen: UIButton = {
        let btn = createNormalButton(backgroundColor: #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1), image: #imageLiteral(resourceName: "stichting_white"), labelText: NSLocalizedString("Charity", comment: ""))
        btn.tag = 100
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Stichtingen", comment: "")
        return btn
    }()
    
    lazy var btnStichtingenSpecial: UIButton = {
        let btn = createSpecialButton(tintColor: #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1), image: #imageLiteral(resourceName: "sugg_stichting_white"), labelText: NSLocalizedString("Charity", comment: ""))
        btn.tag = 100
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Stichtingen", comment: "")
        return btn
    }()
    
    lazy var btnKerken: UIButton = {
        let btn = createNormalButton(backgroundColor: #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1), image: #imageLiteral(resourceName: "church_white"), labelText: NSLocalizedString("Church", comment: ""))
        btn.tag = 101
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Churches", comment: "")
        return btn
    }()
    
    lazy var btnKerkenSpecial: UIButton = {
        let btn = createSpecialButton(tintColor: #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1), image: #imageLiteral(resourceName: "sugg_church_white"), labelText: NSLocalizedString("Church", comment: ""))
        btn.tag = 101
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Churches", comment: "")
        return btn
    }()
    
    lazy var btnActies: UIButton = {
        let btn = createNormalButton(backgroundColor: #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1), image: #imageLiteral(resourceName: "actions_white"), labelText: NSLocalizedString("Campaign", comment: ""))
        btn.tag = 102
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Acties", comment: "")
        return btn
    }()
    
    lazy var btnActiesSpecial: UIButton = {
        let btn = createSpecialButton(tintColor: #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1), image: #imageLiteral(resourceName: "sugg_actions_white"), labelText: NSLocalizedString("Campaign", comment: ""))
        btn.tag = 102
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Acties", comment: "")
        return btn
    }()
    lazy var btnArtiest: UIButton = {
        let btn = createNormalButton(backgroundColor: #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1), image: #imageLiteral(resourceName: "artist"), labelText: NSLocalizedString("Artist", comment: ""))
        btn.tag = 103
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Artists", comment: "")
        return btn
    }()
    
    lazy var btnArtiestSpecial: UIButton = {
        let btn = createSpecialButton(tintColor: #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1), image: #imageLiteral(resourceName: "artist_white"), labelText: NSLocalizedString("Artist", comment: ""))
        btn.tag = 103
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(selectType(_:)))
        btn.addGestureRecognizer(tap)
        btn.accessibilityLabel = NSLocalizedString("Artists", comment: "")
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
        
        var mediumType: MediumHelper.OrganisationType
        
        switch(tag) {
        case 100:
            mediumType = .charity
            navBar.title = NSLocalizedString("Stichtingen", comment: "")
        case 101:
            mediumType = .church
            navBar.title = NSLocalizedString("Churches", comment: "")
        case 102:
            mediumType = .campaign
            navBar.title = NSLocalizedString("Acties", comment: "")
        case 103:
            mediumType = .artist
            navBar.title = NSLocalizedString("Artists", comment: "")
        default:
            mediumType = .invalid
            navBar.title = NSLocalizedString("ChooseWhoYouWantToGiveTo", comment: "")
            break
        }
        
        let countryFilteredList = listToLoad.filter({ (orgBeacon) -> Bool in
            if UserDefaults.standard.paymentType == .Undefined{
#if !PRODUCTION
                if UserDefaults.standard.hackForTesting {
                    return orgBeacon.paymentType.isCreditCard
                }
#endif
                if (NSLocale.current.regionCode == "GB" || NSLocale.current.regionCode == "GG" || NSLocale.current.regionCode == "JE" ){
                    return orgBeacon.paymentType.isBacs
                } else if (Locale.current.regionCode == "US") {
                    return orgBeacon.paymentType.isCreditCard
                } else{
                    return orgBeacon.paymentType.isSepa
                }
            }else{
                return orgBeacon.paymentType == UserDefaults.standard.paymentType
            }
        })
        
        filteredList = countryFilteredList.filter({ (orgBeacon) -> Bool in
            MediumHelper.namespaceToOrganisationType(namespace: orgBeacon.EddyNameSpace) == mediumType || mediumType == .invalid
        })
        
        filteredList?.sort(by: { (first, second) -> Bool in
            return first.OrgName < second.OrgName
        })
        
        originalList = filteredList
        
        if let lastOrg = getPreselectedOrganisation() {
            lastGivtToOrganisationPosition = filteredList?.firstIndex(where: { (org) -> Bool in
                return org.EddyNameSpace == lastOrg
            })
        }
        
        /* if there has been searchd before: filter list */
        filterList()

        loadSections()
        tableView.reloadData()
    }
    
    private func loadSections() {
        /* Show shortcust characters in list */
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
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // deselect row otherwise weird things happen in tableview
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.delegate?.tableView!(tableView, didDeselectRowAt: indexPath)
        }
        
        if !searchText.isEmpty {
            filterList()
        } else {
            filteredList = originalList
        }
        
        loadSections()
        tableView.reloadData()
    }
    
    func filterList() {
        if let searchText = searchBar.text, searchText.count > 0 {
            filteredList = originalList?.filter({ (organisation) -> Bool in
                return organisation.OrgName.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current).contains(searchText.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current))
            })
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

    private func getPreselectedOrganisation() -> String? {
        var namespace: String?

        if let ns = GivtManager.shared.bestBeacon?.namespace {
            namespace = ns
        } else if let savedNamespace = UserDefaults.standard.lastGivtToOrganisationNamespace {
            namespace = savedNamespace
            if let savedName = UserDefaults.standard.lastGivtToOrganisationName {
                guard let _ = GivtManager.shared.orgBeaconList?.first(where: { $0.EddyNameSpace == namespace }) else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "", message: NSLocalizedString("SuggestionNamespaceInvalid", comment: "").replacingOccurrences(of: "{0}", with: savedName), preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    UserDefaults.standard.lastGivtToOrganisationNamespace = nil
                    UserDefaults.standard.lastGivtToOrganisationName = nil
                    return nil
                }
            }
        }
        
        return namespace
    }
}
