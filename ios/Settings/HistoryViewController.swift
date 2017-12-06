//
//  HistoryViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD

class HistoryViewController: UIViewController {
    private var givtService = GivtService.shared
    @IBOutlet var scrlHistory: UIScrollView!
    @IBOutlet var infoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderGivy()
        self.infoButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.show()
        
        getHistory()
    }

    func clearView() {
        historyList.subviews.forEach({ $0.removeFromSuperview()})
    }
    
    @IBOutlet var historyList: UIStackView!
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func renderGivy() {
        containerText = UIView()
        containerText?.translatesAutoresizingMaskIntoConstraints = false
        historyList.addArrangedSubview(containerText!)
        containerText?.topAnchor.constraint(equalTo: historyList.topAnchor).isActive = false
        containerText?.trailingAnchor.constraint(equalTo: historyList.trailingAnchor).isActive = false
        containerText?.leadingAnchor.constraint(equalTo: historyList.leadingAnchor).isActive = false
        
        noGivtsText = UILabel()
        noGivtsText?.text = NSLocalizedString("HistoryIsEmpty", comment: "")
        noGivtsText?.font = UIFont(name: "Avenir-Light", size: 16.0)
        noGivtsText?.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        noGivtsText?.numberOfLines = 0
        noGivtsText?.textAlignment = .center
        noGivtsText?.translatesAutoresizingMaskIntoConstraints = false
        noGivtsText?.lineBreakMode = .byWordWrapping
        containerText?.addSubview(noGivtsText!)
        noGivtsText?.sizeToFit()
        noGivtsText?.leadingAnchor.constraint(equalTo: containerText!.leadingAnchor, constant: 20).isActive = true
        noGivtsText?.topAnchor.constraint(equalTo: containerText!.topAnchor, constant: 20).isActive = true
        noGivtsText?.trailingAnchor.constraint(equalTo: containerText!.trailingAnchor, constant: -20).isActive = true
        noGivtsText?.alpha = 0
        
        let image = #imageLiteral(resourceName: "givymoney.png")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        containerText?.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        imageView.centerXAnchor.constraint(equalTo: containerText!.centerXAnchor, constant: 0).isActive = true
        imageView.topAnchor.constraint(equalTo: noGivtsText!.bottomAnchor, constant: 40).isActive = true
    }
    
    var containerText: UIView? = nil
    var noGivtsText: UILabel? = nil
    var infoScreen: UIView? = nil
    @IBAction func openInfo(_ sender: UIButton) {
        print("user wants to open info")
        infoScreen = UIView()
        infoScreen?.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        self.view.addSubview(infoScreen!)
        infoScreen?.translatesAutoresizingMaskIntoConstraints = false
        infoScreen?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        infoScreen?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        infoScreen?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        //infoScreen?.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        infoScreen?.alpha = 0
        infoScreen?.tag = 1111
        
        let bar = UIView()
        infoScreen?.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
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
    
    func renderNoGivts(){
        SVProgressHUD.dismiss()
        UIView.animate(withDuration: 0.4, animations: {
            self.noGivtsText?.alpha = 1.0
        })
        
    }
    
    func renderBlocks(objects: [HistoryTransaction]) {
        var oldMonth: String = ""
        var oldDay: String = ""
        var oldTime: String = ""
        var prevOrg: String = ""
        var agendaRectangle: AgendaNumber? = nil
        var h: UIStackView? = nil
        var grey: UIView? = nil
        historyList.spacing = 1
        
        let fmt = NumberFormatter()
        fmt.locale = NSLocale.current
        fmt.numberStyle = NumberFormatter.Style.currency
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        fmt.positiveFormat = "¤ #,##0.00"
        
        clearView()
        UIView.animate(withDuration: 0.2, animations: {
            self.infoButton?.alpha = 1
        })
        for (idx, object) in objects.enumerated() {
            /* once per month per year, add title of the month */
            if oldMonth != String(object.timestamp.getMonth()) + "-" + String(object.timestamp.getYear()) {
                
                if idx != 0 {
                    let space = UIView()
                    space.translatesAutoresizingMaskIntoConstraints = false
                    space.heightAnchor.constraint(equalToConstant: 10).isActive = true
                    self.historyList.addArrangedSubview(space)
                }
                
                let purpleBar = UIView()
                purpleBar.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
                purpleBar.translatesAutoresizingMaskIntoConstraints = false
                purpleBar.heightAnchor.constraint(equalToConstant: 30).isActive = true
                self.historyList.addArrangedSubview(purpleBar)
                
                let monthTotal = objects.flatMap { $0 }
                    .filter { ($0.timestamp.getMonth() == object.timestamp.getMonth()) && ($0.timestamp.getYear() == object.timestamp.getYear()) && ($0.status.intValue < 4) }
                var som: Double = 0.0
                for item in monthTotal {
                    som += item.amount
                }
                
                let monthTitle = self.getMonthTitle(name: object.timestamp.getMonthName() + " \'" + object.timestamp.toString("yy"))
                purpleBar.addSubview(monthTitle)
                monthTitle.centerYAnchor.constraint(equalTo: purpleBar.centerYAnchor).isActive = true
                monthTitle.leadingAnchor.constraint(equalTo: purpleBar.leadingAnchor, constant: 10).isActive = true
                
                let text = fmt.string(from: som as NSNumber)
                let monthTotalAmount = self.getMonthTitle(name: text!)
                purpleBar.addSubview(monthTotalAmount)
                monthTotalAmount.centerYAnchor.constraint(equalTo: purpleBar.centerYAnchor).isActive = true
                monthTotalAmount.trailingAnchor.constraint(equalTo: purpleBar.trailingAnchor, constant: -10).isActive = true
            }
            
            //it's a new day
            if oldDay != object.timestamp.toString("MM/dd/yyyy") {
                oldTime = "" //reset oldTime to not hide the time when time would be the same but the day is different DO NOT REMOVE ! ! !
                grey = UIView()
                
                grey!.translatesAutoresizingMaskIntoConstraints = false
                grey!.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.0).isActive = true
                
                self.historyList.addArrangedSubview(grey!)
                
                agendaRectangle = AgendaNumber()
                agendaRectangle!.cornerRadius = 5.0
                agendaRectangle!.backgroundColor = #colorLiteral(red: 0.8232886195, green: 0.8198277354, blue: 0.8529217839, alpha: 1)
                agendaRectangle!.translatesAutoresizingMaskIntoConstraints = false
                grey!.addSubview(agendaRectangle!)
                
                let agendaDay = getAgendaDay(object.timestamp.getDay())
                agendaRectangle!.addSubview(agendaDay)
                
                agendaDay.centerXAnchor.constraint(equalTo: agendaRectangle!.centerXAnchor).isActive = true
                agendaDay.centerYAnchor.constraint(equalTo: agendaRectangle!.centerYAnchor).isActive = true
                
                agendaRectangle!.leadingAnchor.constraint(equalTo: grey!.leadingAnchor, constant: 10.0).isActive = true
                agendaRectangle!.topAnchor.constraint(equalTo: grey!.topAnchor, constant: 10.0).isActive = true
                agendaRectangle!.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
                agendaRectangle!.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                
                h = UIStackView()
                h!.axis = .vertical
                grey!.addSubview(h!)
                h!.translatesAutoresizingMaskIntoConstraints = false
                h!.leadingAnchor.constraint(equalTo: agendaRectangle!.trailingAnchor, constant: 10.0).isActive = true
                let ticketTop = h!.topAnchor.constraint(equalTo: grey!.topAnchor, constant: 10.0)
                ticketTop.isActive = true
                h!.trailingAnchor.constraint(equalTo: grey!.trailingAnchor, constant: -20.0).isActive = true
                h!.bottomAnchor.constraint(equalTo: grey!.bottomAnchor, constant: 0).isActive = true
                
                let churchName = self.getChurchName(name: object.orgName)
                churchName.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
                h!.addArrangedSubview(churchName)
                
            } else {
                if prevOrg != object.orgName {
                    let churchName = self.getChurchName(name: object.orgName)
                    churchName.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
                    h!.addArrangedSubview(churchName)
                }
            }
    
            let collectionStackView2 = UIStackView()
            collectionStackView2.axis = .horizontal
            collectionStackView2.translatesAutoresizingMaskIntoConstraints = false
            h!.addArrangedSubview(collectionStackView2)
            
            collectionStackView2.leadingAnchor.constraint(equalTo: h!.leadingAnchor).isActive = true
            collectionStackView2.trailingAnchor.constraint(equalTo: h!.trailingAnchor).isActive = true
            collectionStackView2.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
            collectionStackView2.backgroundColor = .red
            
            let hour2 = self.getHourLabel(object.timestamp)
            collectionStackView2.addArrangedSubview(hour2)
            collectionStackView2.spacing = 5
            
            hour2.leadingAnchor.constraint(equalTo: collectionStackView2.leadingAnchor, constant: 0.0).isActive = true
            hour2.topAnchor.constraint(equalTo: collectionStackView2.topAnchor, constant: 0.0).isActive = true
            if (hour2.text?.contains("M"))! {
                hour2.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
            } else {
                hour2.widthAnchor.constraint(equalToConstant: 35.0).isActive = true
            }
            
            hour2.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
            
            if oldTime == hour2.text {
                hour2.alpha = 0
            }
            
            oldTime = hour2.text!
            
            let collecte2 = getCollectLabel(text: NSLocalizedString("Collect", comment: "") + " " +  String(describing: object.collectId))
            collectionStackView2.addArrangedSubview(collecte2)
            
            let amount2 = self.getAmountLabel(amount: object.amount, status: object.status, formatter: fmt)
            collectionStackView2.addArrangedSubview(amount2)
            amount2.trailingAnchor.constraint(equalTo: collectionStackView2.trailingAnchor).isActive = true
            amount2.topAnchor.constraint(equalTo: collectionStackView2.topAnchor, constant: 0.0).isActive = true
            amount2.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
            amount2.widthAnchor.constraint(greaterThanOrEqualToConstant: 20.0).isActive = true
            
            collecte2.topAnchor.constraint(equalTo: collectionStackView2.topAnchor, constant: 0.0).isActive = true
            collecte2.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
            
            /* we create a spacer view so the collecte stays right under the church name rather than sit at the bottm */
            let spacer = UIView()
            spacer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            h!.addArrangedSubview(spacer)
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0).isActive = true
            
            oldMonth = String(object.timestamp.getMonth()) + "-" + String(object.timestamp.getYear())
            oldDay = object.timestamp.toString("MM/dd/yyyy")
            prevOrg = object.orgName
        }
        SVProgressHUD.dismiss()
    }
    
    private func getCollectLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir-Roman", size: 14.0)
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 0
        
        return label
    }
    
    private func getAmountLabel(amount: Double, status: NSNumber, formatter: NumberFormatter) -> UILabel {
        let label = UILabel()
        label.text = formatter.string(from: amount as NSNumber)
        label.font = UIFont(name: "Avenir-Heavy", size: 16.0)
        //amount.backgroundColor = .red
        var color = UIColor()
        switch status {
        case 1, 2:
            color = UIColor.init(rgb: 0x2c2b57) //in process
        case 3:
            color = UIColor.init(rgb: 0x41c98e) //processed
        case 4:
            color = UIColor.init(rgb: 0xd43d4c) //refused
        case 5:
            color = UIColor.init(rgb: 0xbcb9c9) //cancelled
        default:
            color = UIColor.init(rgb: 0x2c2b57) //in process
            break
        }
        
        label.textColor = color
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    private func getAgendaDay(_ i: Int) -> UILabel {
        let agendaDay = UILabel()
        agendaDay.text = String(i)
        agendaDay.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        agendaDay.font = UIFont(name: "Avenir-Light", size: 28.0)
        agendaDay.translatesAutoresizingMaskIntoConstraints = false
        return agendaDay
    }
    
    private func getHourLabel(_ timestamp: Date) -> UILabel {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let d = formatter.string(from: timestamp)
        
        let hour = UILabel()
        hour.text = d
        hour.textColor = UIColor.gray
        //hour.backgroundColor = .green
        hour.font = UIFont(name: "Avenir-Medium", size: 12.0)
        hour.translatesAutoresizingMaskIntoConstraints = false
        hour.numberOfLines = 0
        hour.minimumScaleFactor = 0.5
        hour.adjustsFontSizeToFitWidth = true
        return hour
    }
    
    private func getChurchName(name: String) -> UILabel {
        let churchName = UILabel()
        churchName.text = name
        churchName.numberOfLines = 0
        churchName.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        churchName.translatesAutoresizingMaskIntoConstraints = false
        //churchName.backgroundColor = .cyan
        churchName.font = UIFont(name: "Avenir-Heavy", size: 16.0)
        return churchName
    }
    
    private func getMonthTitle(name: String) -> UILabel {
        let label = UILabel()
        label.text = name
        label.numberOfLines = 0
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        //churchName.backgroundColor = .cyan
        label.font = UIFont(name: "Avenir-Heavy", size: 16.0)
        return label
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var models: [HistoryTransaction] = []
    
    func getHistory() {
        givtService.getGivts { (historyTransactions) in
            if historyTransactions.count == 0 {
                DispatchQueue.main.async {
                    self.renderNoGivts()
                }
            } else {
                var objects = historyTransactions.sorted {
                    if $0.timestamp.getYear() != $1.timestamp.getYear() {
                        return $0.timestamp.getYear() > $1.timestamp.getYear()
                    }
                    
                    if $0.timestamp.getMonth() != $1.timestamp.getMonth() {
                        return $0.timestamp.getMonth() > $1.timestamp.getMonth()
                    }
                    
                    if $0.timestamp.getDay() != $1.timestamp.getDay() {
                        return $0.timestamp.getDay() > $1.timestamp.getDay()
                    }
                    
                    if $0.orgName != $1.orgName {
                        return $0.orgName < $1.orgName
                    }
                    
                    if $0.timestamp.getHour() != $1.timestamp.getHour() {
                        return $0.timestamp.getHour() < $1.timestamp.getHour()
                    }
                    
                    if $0.timestamp.getMinutes() != $1.timestamp.getMinutes() {
                        return $0.timestamp.getMinutes() < $1.timestamp.getMinutes()
                    }
                    
                    if $0.timestamp.getSeconds() != $1.timestamp.getSeconds() {
                        return $0.timestamp.getSeconds() < $1.timestamp.getSeconds()
                    }
                    
                    return $0.collectId < $1.collectId
                }
                
                DispatchQueue.main.async {
                    self.renderBlocks(objects: objects)
                }
                    
                    
            }
        }
    }
    
    func renderLabel(model: HistoryTransaction, index: Int) {
        let label = UILabel(frame: CGRect(x: 0, y: 50 * index, width: 200, height: 21))
        label.textAlignment = .center
        label.text = model.orgName
        DispatchQueue.main.async {
            self.scrlHistory.addSubview(label)
        }
        //self.view.addSubview(label)
    }

}

class HistoryTransaction: NSObject {
    public var orgName : String
    public var amount : Double
    public var collectId : Decimal
    public var timestamp : Date
    public var status : NSNumber
    
    /**
     Returns an array of models based on given dictionary.
     
     Sample usage:
     let json4Swift_Base_list = Json4Swift_Base.modelsFromDictionaryArray(someDictionaryArrayFromJSON)
     
     - parameter array:  NSArray from JSON dictionary.
     
     - returns: Array of Json4Swift_Base Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [HistoryTransaction]
    {
        var models:[HistoryTransaction] = []
        for item in array
        {
            models.append(HistoryTransaction(dictionary: item as! Dictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: Dictionary<String, Any>) {

        orgName = (dictionary["OrgName"] as? String)!
        amount = Double((dictionary["Amount"] as? Double)!)
        collectId = Decimal(string: dictionary["CollectId"] as! String)!
        var dateString = (dictionary["Timestamp"] as? String)!
        if dateString.count > 19 {
            dateString = dateString.substring(0..<19)
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = TimeZone(abbreviation: "UTC")
        timestamp = df.date(from: dateString)!
        status = (dictionary["Status"] as? NSNumber)!
    }
    
    public func dictionaryRepresentation() -> Dictionary<String , Any> {
        
        var dictionary = Dictionary<String, Any>()
        dictionary.updateValue(self.orgName, forKey: "OrgName")
        dictionary.updateValue(self.amount, forKey: "Amount")
        dictionary.updateValue(self.collectId, forKey: "CollectId")
        dictionary.updateValue(self.timestamp, forKey: "Timestamp")
        dictionary.updateValue(self.status, forKey: "Status")
        
        return dictionary
    }
    
}

class Status {
    var color: Int
    var string: String
    
    init(color: Int, string: String) {
        self.color = color
        self.string = string
    }
}
