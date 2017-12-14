//
//  AppDelegate.swift
//  ios
//
//  Created by Maarten Vergouwe on 11/07/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import TrustKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var logService: LogService = LogService.shared
    var appService: AppServices = AppServices.shared
    private var reachability: Reachability!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        MSAppCenter.start("e36f1172-f316-4601-81f3-df0024a9860f", withServices:[
            MSAnalytics.self,
            MSCrashes.self
            ])
        
        // Override point for customization after application launch.
        //print(Array(UserDefaults.standard.dictionaryRepresentation()))
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
        
        self.reachability = Reachability.init()
        do {
            try self.reachability.startNotifier()
        } catch {
            
        }
        
        logService.info(message: "App started")
        logService.info(message: "User notification status: " + String(appService.notificationsEnabled()))
        //InfraManager.shared.checkUpdates()
        
        handleOldAppData()
        
        
        TrustKit.initSharedInstance(withConfiguration: AppConstants.trustKitConfig)
        
        return true
    }
    
    func handleOldAppData() {
        let file = "GivtSettings.json"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                print(text2)
                if let data = text2.data(using: .utf8) {
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let myDict = dictionary {
                            if let bearerExpiration = myDict["BearerExpiration"] {
                                UserDefaults.standard.bearerExpiration = Date()
                            }
                            if let amountLimit = myDict["AmountLimit"] as? NSNumber {
                                UserDefaults.standard.amountLimit = amountLimit.intValue
                            }
                            if let bearerToken = myDict["BearerToken"] {
                                UserDefaults.standard.isLoggedIn = true
                                LoginManager.shared.userClaim = .give
                                UserDefaults.standard.bearerToken = String(describing: bearerToken)
                            }
                            if myDict["RequestedPermissions"] != nil {
                                //we do not really use this one...
                            }
                            if let viewedCoachMarks = myDict["ViewedCoachMarks"] as? NSNumber {
                                UserDefaults.standard.viewedCoachMarks = viewedCoachMarks.intValue
                            }
                            if let hasTappedAwayGiveDiff = myDict["HasTappedAwayGiveDiff"] as? NSNumber {
                                UserDefaults.standard.hasTappedAwayGiveDiff = hasTappedAwayGiveDiff.boolValue
                            }
                            if let pinSet = myDict["PinSet"] as? NSNumber {
                                UserDefaults.standard.hasPinSet = pinSet.boolValue
                            }
                            if let mandateSigned = myDict["MandateStatus"] as? NSNumber {
                                UserDefaults.standard.mandateSigned = mandateSigned.boolValue
                            }
                            if let userInfo = myDict["UserInfo"] as? [String: Any] {
                                var newSettings = UserExt()
                                if let userExt = UserDefaults.standard.userExt {
                                    newSettings = userExt
                                }
                                if let address = userInfo["Address"] as? String {
                                    newSettings.address = address
                                }
                                if let city = userInfo["City"] as? String {
                                    newSettings.city = city
                                }
                                if let email = userInfo["Email"] as? String {
                                    newSettings.email = email
                                }
                                if let phoneNumber = userInfo["PhoneNumber"] as? String {
                                    newSettings.mobileNumber = phoneNumber
                                }
                                if let iban = userInfo["IBAN"] as? String{
                                    newSettings.iban = iban
                                }
                                if let firstName = userInfo["FirstName"] as? String {
                                    newSettings.firstName = firstName
                                }
                                if let lastName = userInfo["LastName"] as? String {
                                    newSettings.lastName = lastName
                                }
                                if let guid = userInfo["GUID"] as? String {
                                    newSettings.guid = guid
                                }
                                if let postalCode = userInfo["PostalCode"] as? String {
                                    newSettings.postalCode = postalCode
                                }
                                if let countryCode = userInfo["CountryCode"] as? String {
                                    newSettings.countryCode = countryCode
                                }
                                UserDefaults.standard.userExt = newSettings //update settings
                            }
                        }
                    } catch {
                        logService.warning(message: "Could not read GivtSettings.json")
                    }
                    
                    do {
                        try "".write(to: fileURL, atomically: true, encoding: .utf8)
                    } catch {
                        logService.warning(message: "Could not empty GivtSettings.json!")
                        LoginManager.shared.logout()
                    }
                
                }
            }
            catch {
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        logService.info(message: "App paused")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        logService.info(message: "App resuming")
        NavigationManager.shared.resume()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        logService.info(message: "App is terminating")
    }
    
    @objc func reachabilityChanged(notification:Notification) {
        let reachability = notification.object as! Reachability
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                logService.info(message: "App got connected over WiFi")
            } else {
                print("Reachable via Cellular")
                logService.info(message: "App got connected over Cellular")
            }
        } else {
            print("Network not reachable")
            logService.info(message: "App got disconnected")
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        //
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            //todo find share my givt and show the share method 
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let host = url.host, host == "sharemygivt" {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                var message = !GivtService.shared.lastGivtOrg.isEmpty() ? NSLocalizedString("ShareTheGivtTextNoOrg", comment: "") : NSLocalizedString("ShareTheGivtText", comment: "").replacingOccurrences(of: "{0}", with: GivtService.shared.lastGivtOrg)
                message += " " + NSLocalizedString("JoinGivt", comment: "")
                let activityViewController = UIActivityViewController(activityItems: [message as NSString], applicationActivities: nil)
                topController.present(activityViewController, animated: true, completion: nil)
                logService.info(message: "A Givt is being shared via the Safari-flow")
            }
        
        }
        return true
    }



}

