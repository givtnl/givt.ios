//
//  DiscoverOrAmountSelectDestinationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 28/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import AppCenterAnalytics
import Mixpanel

class DiscoverOrAmountSelectDestinationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    var destinations = [DestinationViewModel]()
    var filteredDestinations = [DestinationViewModel]()
    var sections = [TableSection]()
    var mediater: MediaterWithContextProtocol = Mediater.shared
    var action: DiscoverOrAmountActions!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var typeStackView: UIStackView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navBar: UINavigationItem!
    
    var churchButton: DestinationCategoryButton!
    var charityButton: DestinationCategoryButton!
    var campaignButton: DestinationCategoryButton!
    var artistButton: DestinationCategoryButton!
    
    private var actionSheet: UIAlertController? = nil
    
    //MARK: viewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "SelectRecipient".localized
        navigationItem.accessibilityLabel = "SelectRecipient".localized
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
        
        setupActionSheet()
        
        var comingFromBudget = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
        
        searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.sectionIndexMinimumDisplayRowCount = 20
        tableView.sectionIndexColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        tableView.sectionIndexBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        tableView.tableFooterView = UIView(frame: .zero)
        
        backButton.accessibilityLabel = "Back".localized
        churchButton = DestinationCategoryButton(color: ColorHelper.Church, imageWhenInactive: #imageLiteral(resourceName: "church_white"), imageWhenActive: #imageLiteral(resourceName: "sugg_church_white"), labelText: "Church".localized, tag: CollectGroupType.church.rawValue)
        churchButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        charityButton = DestinationCategoryButton(color: ColorHelper.Charity, imageWhenInactive: #imageLiteral(resourceName: "stichting_white"), imageWhenActive: #imageLiteral(resourceName: "sugg_stichting_white"), labelText: "Charity".localized, tag: CollectGroupType.charity.rawValue)
        charityButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        campaignButton = DestinationCategoryButton(color: ColorHelper.Action, imageWhenInactive: #imageLiteral(resourceName: "actions_white"), imageWhenActive: #imageLiteral(resourceName: "sugg_actions_white"), labelText: "Campaign".localized, tag: CollectGroupType.campaign.rawValue)
        campaignButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        artistButton = DestinationCategoryButton(color: ColorHelper.Artist, imageWhenInactive: #imageLiteral(resourceName: "artist"), imageWhenActive: #imageLiteral(resourceName: "artist_white"), labelText: "Artist".localized, tag: CollectGroupType.artist.rawValue)
        artistButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        typeStackView.addArrangedSubview(churchButton)
        typeStackView.addArrangedSubview(charityButton)
        typeStackView.addArrangedSubview(campaignButton)
        typeStackView.addArrangedSubview(artistButton)
        
        loadDestinations()
        handleDestinationAction(action: action)
        filterDestinationsAndReloadTable()
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainViewRoute(), withContext: self)
    }
}

extension DiscoverOrAmountSelectDestinationViewController {
    func setupActionSheet() {
        actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let oneTime: UIAlertAction = UIAlertAction(title: "DiscoverOrAmountActionSheetOnce".localized, style: .default) { (action) in
            if let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as? DestinationTableCell {
                if let mediumId = ((try? self.mediater.send(request: GetCollectGroupsQuery()).first { $0.name == selectedCell.name }))?.namespace {
                    try? self.mediater.send(request: DiscoverOrAmountOpenSetupSingleDonationRoute(name: selectedCell.name, mediumId: mediumId), withContext: self)
                }
            }
        }
        let recurring: UIAlertAction = UIAlertAction(title: "DiscoverOrAmountActionSheetRecurring".localized, style: .default) { (action) in
            if let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as? DestinationTableCell {
                if let medium = ((try? self.mediater.send(request: GetCollectGroupsQuery()).first { $0.name == selectedCell.name })) {
                    try? self.mediater.send(request: DiscoverOrAmountOpenSetupRecurringDonationRoute(name: selectedCell.name, mediumId: medium.namespace, orgType: medium.type), withContext: self)
                }
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "CancelShort".localized, style: .cancel)
        actionSheet?.addAction(oneTime)
        if LoginManager.shared.isFullyRegistered {
            actionSheet?.addAction(recurring)
        }
        actionSheet?.addAction(cancelAction)
    }
    
    func handleDestinationAction(action: DiscoverOrAmountActions) {
        switch action {
        case .search:
            searchBar.becomeFirstResponder()
        case .charities:
            let gestureRecognizer = charityButton.gestureRecognizers?.first as! UITapGestureRecognizer
            categoryButtonTapped(gestureRecognizer)
        case .churches:
            let gestureRecognizer = churchButton.gestureRecognizers?.first as! UITapGestureRecognizer
            categoryButtonTapped(gestureRecognizer)
        case .campaigns:
            let gestureRecognizer = campaignButton.gestureRecognizers?.first as! UITapGestureRecognizer
            categoryButtonTapped(gestureRecognizer)
        case .artists:
            let gestureRecognizer = artistButton.gestureRecognizers?.first as! UITapGestureRecognizer
            categoryButtonTapped(gestureRecognizer)
        default:
            return
        }
    }
    //MARK: tableFiltering
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // deselect row otherwise weird things happen in tableview
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.delegate?.tableView!(tableView, didDeselectRowAt: indexPath)
        }
        
        filterDestinationsAndReloadTable()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    @objc func categoryButtonTapped(_ sender: UITapGestureRecognizer) {
        if let button = sender.view as? DestinationCategoryButton {
            //replace already active button with inactive button
            if let prevButton = (typeStackView.arrangedSubviews.filter { view in
                let btn = view as? DestinationCategoryButton
                return button != btn && btn?.active ?? false
            }.first as? DestinationCategoryButton) {
                let idx = typeStackView.arrangedSubviews.firstIndex(of: prevButton)
                typeStackView.removeArrangedSubview(prevButton)
                prevButton.removeFromSuperview()
                prevButton.setInactive()
                typeStackView.insertArrangedSubview(prevButton, at: idx!)
            }
            
            //replace tapped button with newly styled button
            if let idx = typeStackView.arrangedSubviews.firstIndex(of: button) {
                typeStackView.removeArrangedSubview(button)
                button.removeFromSuperview()
                if button.active {
                    button.setInactive()
                } else {
                    button.setActive()
                }
                typeStackView.insertArrangedSubview(button, at: idx)
            }
            
            filterDestinationsAndReloadTable()
        }
    }
    //MARK: tableSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.title }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].length
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    //MARK: table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let destination = filteredDestinations[sections[indexPath.section].index + indexPath.row]
        let destinationCell = (tableView.dequeueReusableCell(withIdentifier: String(describing: DestinationTableCell.self), for: indexPath) as! DestinationTableCell)
        destinationCell.name = destination.name
        destinationCell.type = destination.type
        destinationCell.iconRight = destination.iconRight
        if destination.selected {
            //select row that should be selected
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return destinationCell
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        // update ViewModel
        if let destinationCell = tableView.cellForRow(at: indexPath) as? DestinationTableCell {
            (destinations.first { $0.name == destinationCell.name })!.selected = false
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        view.endEditing(true)
        
        let deselectRowFunction: (_ path: IndexPath) -> Void = { path in
            tableView.deselectRow(at: path, animated: false)
            _ = tableView.delegate!.tableView?(tableView, willDeselectRowAt: path)
            tableView.delegate!.tableView?(tableView, didDeselectRowAt: path)
        }
        
        if let indexPaths = tableView.indexPathsForSelectedRows {
            if (indexPaths.contains { $0 == indexPath }) {
                // deselect when tapped again
                deselectRowFunction(indexPath)
                return nil //make sure selection doesn't continue
            }
        }
        if ( (tableView.cellForRow(at: indexPath) as! DestinationTableCell).type == CollectGroupType.none) {
            // deselect previous selected row
            tableView.indexPathsForSelectedRows?.forEach { selectedIndexPath in
                deselectRowFunction(selectedIndexPath)
            }
            // This is the special "report missing organisation item"
            try? self.mediater.send(request: GoToAboutViewRoute(), withContext: self)
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let destinationCell = tableView.cellForRow(at: indexPath) as? DestinationTableCell {
            
            if let popoverController = actionSheet?.popoverPresentationController {
                popoverController.sourceView = destinationCell
            }
            
            self.present(actionSheet!, animated: true, completion: nil)
            // update ViewModel
            (destinations.first { $0.name == destinationCell.name })!.selected = true
            // make sure other destinations are deselected
            destinations.filter { $0.name != destinationCell.name }.forEach { $0.selected = false }
        }
    }
    
    private func loadDestinations() {
        let userDetail = try? mediater.send(request: GetLocalUserConfiguration())
        try? mediater.sendAsync(request: GetCollectGroupsQuery()) { response in
            self.destinations = response.filter({ (orgBeacon) -> Bool in
                    if (UserDefaults.standard.paymentType == .Undefined){
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
                }) // only show destinations that the user can give to with his account
                .map { cg in
                    let destination = DestinationViewModel()
                    destination.name = cg.name
                    destination.type = cg.type
                    destination.selected = false
                    return destination
                }
        }
        
        let missingOrganisationElement = DestinationViewModel()
        missingOrganisationElement.name = NSLocalizedString("ReportMissingOrganisationListItem", comment: "")
        missingOrganisationElement.selected = false
        missingOrganisationElement.iconRight = "plus"
        missingOrganisationElement.type = CollectGroupType.none
        
        self.destinations.insert(missingOrganisationElement, at: 0)
    }
    
    private func filterDestinationsAndReloadTable() {
        filteredDestinations = destinations
        
        if let activeCategoryButton = typeStackView.arrangedSubviews.first(where: { view in
            return (view as! DestinationCategoryButton).active
        }) {
            filteredDestinations = filteredDestinations.filter { $0.type == CollectGroupType(rawValue: activeCategoryButton.tag) || $0.type == CollectGroupType.none }
        }
        
        if let currentSearchText = searchBar.text, !currentSearchText.isEmpty {
            filteredDestinations = filteredDestinations.filter {
                $0.name.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current).contains(currentSearchText.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current)) || $0.type == CollectGroupType.none}
        }
        
        buildTableSections()
        
        //deselect all cells before loading
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for path in indexPaths {
                tableView.deselectRow(at: path, animated: false)
                tableView.delegate!.tableView?(tableView, didDeselectRowAt: path)
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func buildTableSections() {
        if filteredDestinations.count > 0 {
            let names = filteredDestinations.map { $0.name }
            var firstCharacters = names.map { $0.first! }
            firstCharacters = Array(Set(firstCharacters)).sorted()
            sections = firstCharacters.map { fc in
                let firstNameWithCharacter = names.sorted().firstIndex { String($0.first!) == String(fc) }
                let lastNameWithCharacter = names.sorted().lastIndex { String($0.first!) == String(fc) }
                return TableSection(index: firstNameWithCharacter!, length: lastNameWithCharacter! - firstNameWithCharacter! + 1, title: String(fc))
            }
            return
        }
        sections = [TableSection]()
    }
}
