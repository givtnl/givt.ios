//
//  ChooseDestinationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

class SetupRecurringDonationChooseDestinationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    var destinations = [DestinationViewModel]()
    var filteredDestinations = [DestinationViewModel]()
    var sections = [TableSection]()
    var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var typeStackView: UIStackView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var nextButton: CustomButton!

    var churchButton: DestinationCategoryButton!
    var charityButton: DestinationCategoryButton!
    var campaignButton: DestinationCategoryButton!
    var artistButton: DestinationCategoryButton!

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
        let destinationCell = tableView.dequeueReusableCell(withIdentifier: String(describing: DestinationTableCell.self), for: indexPath) as! DestinationTableCell
        destinationCell.name = destination.name
        destinationCell.type = destination.type
        if destination.selected {
            //select row that should be selected
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            destinationCell.toggleOn()
            nextButton.isEnabled = true
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
        if let destinationCell = tableView.cellForRow(at: indexPath) as? DestinationTableCell {
            destinationCell.toggleOff()
            nextButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            if (indexPaths.contains { $0 == indexPath }) {
                // deselect when tapped again
                tableView.deselectRow(at: indexPath, animated: false)
                _ = tableView.delegate!.tableView?(tableView, willDeselectRowAt: indexPath)
                tableView.delegate!.tableView?(tableView, didDeselectRowAt: indexPath)
                return nil //make sure selection doesn't continue
            }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let destinationCell = tableView.cellForRow(at: indexPath) as? DestinationTableCell {
            destinationCell.toggleOn()
            nextButton.isEnabled = true
            // update ViewModel
            (destinations.first { $0.name == destinationCell.name })!.selected = true
            // make sure other destinations are deselected
            destinations.filter { $0.name != destinationCell.name }.forEach { $0.selected = false }
        }
    }
    
    //MARK: viewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_first"))
        navigationItem.accessibilityLabel = NSLocalizedString("ProgressBarStepOne", comment: "")
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleText.text = "ChooseWhoYouWantToGiveTo".localized

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
        
        searchBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.sectionIndexMinimumDisplayRowCount = 20
        tableView.sectionIndexColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        tableView.sectionIndexBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        tableView.tableFooterView = UIView(frame: .zero)

        nextButton.setTitle(NSLocalizedString("Next", comment: "Button to give"), for: UIControlState.normal)
        nextButton.isEnabled = false
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        churchButton = DestinationCategoryButton(color: #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1), imageWhenInactive: #imageLiteral(resourceName: "church_white"), imageWhenActive: #imageLiteral(resourceName: "sugg_church_white"), labelText: "Church".localized, tag: CollectGroupType.church.rawValue)
        churchButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        charityButton = DestinationCategoryButton(color: #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1), imageWhenInactive: #imageLiteral(resourceName: "stichting_white"), imageWhenActive: #imageLiteral(resourceName: "sugg_stichting_white"), labelText: "Charity".localized, tag: CollectGroupType.charity.rawValue)
        charityButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        campaignButton = DestinationCategoryButton(color: #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1), imageWhenInactive: #imageLiteral(resourceName: "actions_white"), imageWhenActive: #imageLiteral(resourceName: "sugg_actions_white"), labelText: "Campaign".localized, tag: CollectGroupType.campaign.rawValue)
        campaignButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        artistButton = DestinationCategoryButton(color: #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1), imageWhenInactive: #imageLiteral(resourceName: "artist"), imageWhenActive: #imageLiteral(resourceName: "artist_white"), labelText: "Artist".localized, tag: CollectGroupType.artist.rawValue)
        artistButton.addTapGesture(self, action: #selector(categoryButtonTapped(_:)))
        typeStackView.addArrangedSubview(churchButton)
        typeStackView.addArrangedSubview(charityButton)
        typeStackView.addArrangedSubview(campaignButton)
        typeStackView.addArrangedSubview(artistButton)
        
        loadDestinations()
        filterDestinationsAndReloadTable()
    }
    
    //MARK: nextButton
    @IBAction func nextButtonTapped(_ sender: Any) {
        do {
            if let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? DestinationTableCell,
               let mediumId = ((try mediater.send(request: GetCollectGroupsQuery())).first { $0.name == selectedCell.name })?.namespace {
                try mediater.send(request: SetupRecurringDonationOpenSubscriptionRoute(name: selectedCell.name, mediumId: mediumId), withContext: self)
            }
        } catch {}
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
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
                let idx = typeStackView.arrangedSubviews.index(of: prevButton)
                typeStackView.removeArrangedSubview(prevButton)
                prevButton.removeFromSuperview()
                prevButton.setInactive()
                typeStackView.insertArrangedSubview(prevButton, at: idx!)
            }

            //replace tapped button with newly styled button
            if let idx = typeStackView.arrangedSubviews.index(of: button) {
                typeStackView.removeArrangedSubview(button)
                button.removeFromSuperview()
                if button.active {
                    button.setInactive()
                    titleText.text = "ChooseWhoYouWantToGiveTo".localized
                } else {
                    button.setActive()
                    titleText.text = button.labelText
                }
                typeStackView.insertArrangedSubview(button, at: idx)
            }
            
            filterDestinationsAndReloadTable()
        }
    }
    
    private func loadDestinations() {
        let userDetail = try? mediater.send(request: GetLocalUserConfiguration())
        try? mediater.sendAsync(request: GetCollectGroupsQuery()) { response in
            self.destinations = response
                .filter { $0.paymentType == userDetail?.paymentType } // only show destinations that the user can give to with his account
                .map { cg in
                    let destination = DestinationViewModel()
                    destination.name = cg.name
                    destination.type = cg.type
                    destination.selected = false
                    return destination
                }
        }
    }
    
    private func filterDestinationsAndReloadTable() {
        filteredDestinations = destinations
        if let currentSearchText = searchBar.text, !currentSearchText.isEmpty {
            filteredDestinations = filteredDestinations.filter { $0.name.contains(currentSearchText) }
        }
        
        if let activeCategoryButton = typeStackView.arrangedSubviews.first(where: { view in
            return (view as! DestinationCategoryButton).active
        }) {
            filteredDestinations = filteredDestinations.filter { $0.type == CollectGroupType(rawValue: activeCategoryButton.tag) }
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
