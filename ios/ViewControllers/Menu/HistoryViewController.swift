    //
//  HistoryViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwipeCellKit

class HistoryViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    private var givtService = GivtService.shared
    private var overlay: UIView?
    private var balloon: Balloon?
    
    var models: [HistoryTransaction] = []
    var tempArray: [String: [HistoryTableViewModel]] = [String: [HistoryTableViewModel]]()
    var sortedArray: [(key: String, value: [HistoryTableViewModel])] = [(key: String, value: [HistoryTableViewModel])]()
    var infoScreen: UIView? = nil
    
    @IBOutlet var parentView: UIView!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var givyContainer: UIView!
    @IBOutlet var noGivtsLabel: UILabel!
    @IBOutlet var containerButton: UIBarButtonItem!
    @IBOutlet var containerVIew: UIView!
    
    lazy var fmt: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = NSLocale.current
        nf.currencySymbol = "€"
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        nf.positiveFormat = "¤ #,##0.00"
        return nf
    }()
    
    lazy var timeFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "H:mm:ss"
        return formatter
    }()
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let tx = self.sortedArray[indexPath.section].value[indexPath.row]
        let currentDate = Date()
        let calendar = Calendar.current
        guard let newDate = calendar.date(byAdding: Calendar.Component.minute, value: -15, to: currentDate) else { return nil }
        if tx.timestamp < newDate {
            print("can't swipe this transaction")
            return nil
        }
        
        guard orientation == .right else { return nil }

        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("CancelShort", comment: "")) { action, indexPath in
            // handle action by updating model with deletion
            self.sortedArray[indexPath.section].value[indexPath.row].collections.forEach {
                print($0.transactionId)
            }
            self.sortedArray[indexPath.section].value.remove(at: indexPath.row)
            
            
            action.fulfill(with: .delete)
            
            if let section = tableView.headerView(forSection: indexPath.section) as? TableSectionHeader {
                let elligibleTx = self.sortedArray[indexPath.section].value.filter { (tx) -> Bool in
                    return tx.status.intValue < 4
                }
                var total = 0.00
                elligibleTx.forEach { (tx) in
                    tx.collections.forEach({ (collecte) in
                        total += collecte.amount
                    })
                }
                section.amountLabel.text = self.fmt.string(from: total as! NSNumber)
            }
            
            if self.sortedArray.count == 1 && self.sortedArray[indexPath.section].value.count == 0 {
                self.givyContainer.isHidden = false
            }
            
        }
        
        // customize the action appearance
        deleteAction.image = #imageLiteral(resourceName: "trash")
        deleteAction.backgroundColor = #colorLiteral(red: 0.7254901961, green: 0.1019607843, blue: 0.1411764706, alpha: 1)
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = SwipeExpansionStyle.destructive
        options.transitionStyle = .reveal
        
        return options
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TableSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeaderView")
        
        noGivtsLabel.text = NSLocalizedString("HistoryIsEmpty", comment: "")
        givyContainer.isHidden = false
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.show()
        
        //scrollView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getHistory()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedScrollView(sender:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        //scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        self.downloadButton.isHidden = !UserDefaults.standard.hasGivtsInPreviousYear
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tx = sortedArray[section].value.first else { return nil }
        let title = tx.timestamp.getMonthName() + " \'" + tx.timestamp.toString("yy")
        let elligibleTx = sortedArray[section].value.filter { (tx) -> Bool in
            return tx.status.intValue < 4
        }
        var total = 0.00
        elligibleTx.forEach { (tx) in
            tx.collections.forEach({ (collecte) in
                total += collecte.amount
            })
        }
        
        // Dequeue with the reuse identifier
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeaderView")
        let header = cell as! TableSectionHeader
        header.titleLabel.text = title
        header.amountLabel.text = fmt.string(from: total as! NSNumber)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sortedArray[section].value.count > 0 {
            return 30
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as! HistoryTableViewCell
        cell.delegate = self
        let tx = sortedArray[indexPath.section].value[indexPath.row]
        cell.organisationLabel.text = tx.orgName
        cell.setCollects(collects: tx.collections)
        cell.dayNumber.text = String(tx.timestamp.getDay())
        cell.timeLabel.text = timeFormatter.string(from: tx.timestamp)
        cell.setColor(status: tx.status.intValue)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.red
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = title.font
        header.textLabel!.textColor = title.textColor
        header.contentView.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.showedLastYearTaxOverview && UserDefaults.standard.hasGivtsInPreviousYear {
            showOverlay()
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tappedScrollView(sender: UITapGestureRecognizer) {
        hideOverlay()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideOverlay()
    }

    
    func showOverlay() {
        if let window = UIApplication.shared.keyWindow {
            self.balloon = Balloon(text: NSLocalizedString("CheckHereForYearOverview", comment: ""))
            self.view.addSubview(self.balloon!)
            
            var cgRectOfButton = CGRect()
            if #available(iOS 11.0, *) {
                cgRectOfButton = self.downloadButton.convert(self.downloadButton.frame, to: nil)
            } else {
                cgRectOfButton = (self.containerButton.value(forKey: "view") as! UIView).frame
            }
            let offSet = cgRectOfButton.midX - self.tableView.frame.midX
            self.balloon!.centerTooltip(view: self.tableView, offSet)
            
            
            self.balloon!.pinRight(view: self.tableView, -5)
            
            self.balloon!.pinTop2(view: self.view, self.containerVIew.frame.minY + 5)
            self.view.bringSubview(toFront: self.balloon!)
            self.view.layoutIfNeeded()
            
            self.balloon!.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.balloon!.alpha = 1
            }
            
            self.balloon?.bounce()
            
            self.overlay = UIView()
            self.overlay!.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.overlay!.translatesAutoresizingMaskIntoConstraints = false
            self.containerVIew.addSubview(self.overlay!)
            self.overlay!.topAnchor.constraint(equalTo: self.containerVIew.topAnchor).isActive = true
            self.overlay!.bottomAnchor.constraint(equalTo: self.containerVIew.bottomAnchor).isActive = true
            self.overlay!.leadingAnchor.constraint(equalTo: self.containerVIew.leadingAnchor).isActive = true
            self.overlay!.trailingAnchor.constraint(equalTo: self.containerVIew.trailingAnchor).isActive = true
            self.overlay!.alpha = 0.6
            
            UserDefaults.standard.showedLastYearTaxOverview = true
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if let touchedView = touch.view {
                if touchedView == self.overlay {
                    hideOverlay()
                }
            }
        }
    }
    
    func hideOverlay() {
        overlay?.removeFromSuperview()
        balloon?.removeFromSuperview()
    }
    @IBAction func openOverViewPage(_ sender: Any) {
            if self.balloon != nil {
                NSLayoutConstraint.deactivate((self.balloon?.constraints)!)
            }
            
            self.hideOverlay()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TaxesViewController") as! TaxesViewController
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    @IBAction func openInfo(_ sender: Any) {
        print("user wants to open info")
        infoScreen = UIView()
        infoScreen?.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        self.navigationController?.view.addSubview(infoScreen!)
        infoScreen?.translatesAutoresizingMaskIntoConstraints = false
        infoScreen?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        infoScreen?.topAnchor.constraint(equalTo: (self.navigationController?.view.topAnchor)!).isActive = true
        infoScreen?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        //infoScreen?.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        infoScreen?.alpha = 0
        infoScreen?.tag = 1111
        
        let bar = UIView()
        infoScreen?.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.topAnchor.constraint(equalTo: (self.navigationController?.topLayoutGuide.bottomAnchor)!, constant: 0).isActive = true
        bar.leadingAnchor.constraint(equalTo: (infoScreen?.leadingAnchor)!, constant: 0).isActive = true
        bar.trailingAnchor.constraint(equalTo: (infoScreen?.trailingAnchor)!, constant: 0).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let infoGivts = UILabel()
        infoGivts.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(infoGivts)
        infoGivts.centerXAnchor.constraint(equalTo: bar.centerXAnchor, constant: 0).isActive = true
        infoGivts.centerYAnchor.constraint(equalTo: bar.centerYAnchor, constant: 0).isActive = true
        infoGivts.text = NSLocalizedString("HistoryInfoTitle", comment: "")
        infoGivts.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        infoGivts.textColor = .white
        
        let closeButton = UIButton()
        bar.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        closeButton.topAnchor.constraint(equalTo: bar.topAnchor, constant: 0).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 0).isActive = true
        closeButton.setImage(#imageLiteral(resourceName: "closewhite.png"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeInfo), for: .touchUpInside)
        closeButton.showsTouchWhenHighlighted = false
        
        let demStates = UIStackView()
        demStates.axis = .vertical
        demStates.spacing = 25
        demStates.translatesAutoresizingMaskIntoConstraints = false
        infoScreen?.addSubview(demStates)
        demStates.leadingAnchor.constraint(equalTo: (infoScreen?.leadingAnchor)!, constant: 25).isActive = true
        demStates.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 15).isActive = true
        demStates.trailingAnchor.constraint(equalTo: (infoScreen?.trailingAnchor)!, constant: -15).isActive = true
        demStates.bottomAnchor.constraint(equalTo: (infoScreen?.bottomAnchor)!, constant: -15).isActive = true
        
        var states: [Status] = [Status]()
        states.append(Status(color: 0x494874, string: NSLocalizedString("HistoryAmountAccepted", comment: "")))
        states.append(Status(color: 0x41c98e, string: NSLocalizedString("HistoryAmountCollected", comment: "")))
        states.append(Status(color: 0xd43d4c, string: NSLocalizedString("HistoryAmountDenied", comment: "")))
        states.append(Status(color: 0xbcb9c9, string: NSLocalizedString("HistoryAmountCancelled", comment: "")))
        
        states.forEach {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false
            demStates.addArrangedSubview(row)
            row.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            
            let bolleke = UIView()
            bolleke.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(bolleke)
            bolleke.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 0).isActive = true
            bolleke.centerYAnchor.constraint(equalTo: row.centerYAnchor, constant: 0).isActive = true
            
            bolleke.backgroundColor = UIColor.init(rgb: $0.color)
            bolleke.widthAnchor.constraint(equalToConstant: 15).isActive = true
            bolleke.heightAnchor.constraint(equalToConstant: 15).isActive = true
            bolleke.layer.cornerRadius = 7.5
            
            let statusLabel = UILabel()
            statusLabel.text = $0.string
            statusLabel.textColor = .white
            statusLabel.font = UIFont(name: "Avenir-Medium", size: 16.0)
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(statusLabel)
            statusLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor, constant: 0).isActive = true
            statusLabel.leadingAnchor.constraint(equalTo: bolleke.trailingAnchor, constant: 22).isActive = true
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.infoScreen?.alpha = 1
            UIApplication.shared.statusBarStyle = .lightContent
        })

        
    }
    
    @objc func closeInfo() {
        UIView.animate(withDuration: 0.2, animations: {
            self.infoScreen?.alpha = 0
            UIApplication.shared.statusBarStyle = .default
        })
    }

    func getHistory() {
        givtService.getGivts { (historyTransactions) in
            if historyTransactions.count == 0 {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.givyContainer.isHidden = false
                    self.infoButton.isHidden = true
                }
            } else {
                self.models = historyTransactions.sorted {
                    if $0.timestamp.getYear() != $1.timestamp.getYear() {
                        return $0.timestamp.getYear() > $1.timestamp.getYear()
                    }
                    
                    if $0.timestamp.getMonth() != $1.timestamp.getMonth() {
                        return $0.timestamp.getMonth() > $1.timestamp.getMonth()
                    }
                    
                    if $0.timestamp.getDay() != $1.timestamp.getDay() {
                        return $0.timestamp.getDay() > $1.timestamp.getDay()
                    }
                    
//                    if $0.orgName != $1.orgName {
//                        return $0.orgName < $1.orgName
//                    }
                    
                    if $0.timestamp.getHour() != $1.timestamp.getHour() {
                        return $0.timestamp.getHour() > $1.timestamp.getHour()
                    }
                    
                    if $0.timestamp.getMinutes() != $1.timestamp.getMinutes() {
                        return $0.timestamp.getMinutes() > $1.timestamp.getMinutes()
                    }
                    
                    if $0.timestamp.getSeconds() != $1.timestamp.getSeconds() {
                        return $0.timestamp.getSeconds() > $1.timestamp.getSeconds()
                    }
                    
                    return $0.collectId < $1.collectId
                }
                
                var newTransactions = [HistoryTableViewModel]()
                var oldDate: Date?
                var oldOrgName: String?
                var oldStatus: NSNumber?
                self.models.forEach({ (tx) in
                    // check if transaction with current date exists and is to same organsation
                    
                    if let oDate = oldDate, let oOrgName = oldOrgName, let oStatus = oldStatus {
                        var existingTx = newTransactions.filter({ (newTx) -> Bool in
                            newTx.orgName == tx.orgName && newTx.timestamp.toString("yyyy-MM-dd'T'HH:mm:ssZ") == tx.timestamp.toString("yyyy-MM-dd'T'HH:mm:ssZ") && tx.status == newTx.status
                        })
                        
                        if existingTx.count > 0 {
                            existingTx.first!.collections.append(Collecte(transactionId: tx.id, collectId: tx.collectId, amount: tx.amount, amountString: self.fmt.string(from: tx.amount as! NSNumber)!))
                        } else {
                            // does not exist
                            var collections = [Collecte]()
                            collections.append(Collecte(transactionId: tx.id, collectId: tx.collectId, amount: tx.amount, amountString: self.fmt.string(from: tx.amount as! NSNumber)!))
                            let newTx = HistoryTableViewModel(orgName: tx.orgName, timestamp: tx.timestamp, status: tx.status, collections: collections)
                            newTransactions.append(newTx)
                        }
                    } else {
                        // first time
                        var collections = [Collecte]()
                        collections.append(Collecte(transactionId: tx.id, collectId: tx.collectId, amount: tx.amount, amountString: self.fmt.string(from: tx.amount as! NSNumber)!))
                        let newTx = HistoryTableViewModel(orgName: tx.orgName, timestamp: tx.timestamp, status: tx.status, collections: collections)
                        newTransactions.append(newTx)
                    }
                    
                    
                    oldDate = tx.timestamp
                    oldOrgName = tx.orgName
                    oldStatus = tx.status
                })
            
                newTransactions.forEach({ (tx) in
                    var monthString = String(tx.timestamp.getMonth())
                    monthString = monthString.count == 1 ? "0" + monthString : monthString
                    let s = String(tx.timestamp.getYear()) + " - " + monthString
                    if self.tempArray.keys.contains(s) {
                        self.tempArray[s]!.append(tx)
                    } else {
                        self.tempArray[s] = [HistoryTableViewModel]()
                        self.tempArray[s]!.append(tx)
                    }

                })
                
                self.sortedArray = self.tempArray.sorted(by: { (first, second) -> Bool in
                    first.key > second.key
                })
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                    self.givyContainer.isHidden = true
                }
            }
        }
    }

    @IBAction func clearViewed2017(_ sender: Any) {
        UserDefaults.standard.showedLastYearTaxOverview = false
    }
}
