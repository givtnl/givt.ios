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
import AppCenterPush
import TrustKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var logService: LogService = LogService.shared
    var appService: AppServices = AppServices.shared
    
    var loginManager: LoginManager = LoginManager.shared
    
    var coreDataContext = CoreDataContext()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        TrustKit.initSharedInstance(withConfiguration: AppConstants.trustKitConfig) //must be called first in order to call the apis
        MSAppCenter.start(AppConstants.appcenterId, withServices:[
                MSAnalytics.self,
                MSCrashes.self
            ])
        
        if MSCrashes.hasCrashedInLastSession()  {
            logService.error(message: "User had a crash, check AppCenter")
        }

        registerHandlers()
        
        logService.info(message: "App started")
        
        if !UserDefaults.standard.showcases.isEmpty {
            UserDefaults.standard.showCasesByUserID = UserDefaults.standard.showcases
            UserDefaults.standard.showcases = []
        }
        
        NotificationManager.shared.start()
        
        handleOldBeaconList()
        checkIfTempUser()
        doMagicForPresets()
        
        if let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification], let pushNotificationInfo = remoteNotif as? [AnyHashable : Any] {
            DispatchQueue.global(qos: .background).async {
                NotificationManager.shared.processPushNotification(fetchCompletionHandler: {result in }, pushNotificationInfo: pushNotificationInfo )
            }
        }
        
        return true
    }
    
    func doMagicForPresets() {
        if(UserDefaults.standard.object(forKey: UserDefaults.UserDefaultsKeys.presetsSet.rawValue) == nil){
            UserDefaults.standard.hasPresetsSet = UserDefaults.standard.userExt?.guid != nil
        }
    }
    
    func checkIfTempUser() {
        guard let userExt = UserDefaults.standard.userExt else { return }
        LoginManager.shared.doesEmailExist(email: userExt.email) { (status) in
            if status == "true" { //completed registration
                UserDefaults.standard.isTempUser = false
            } else if status == "false" { //email is completely new
                UserDefaults.standard.isTempUser = true
            } else if status == "temp" || status == "dashboard" { //email is in db but not succesfully registered
                UserDefaults.standard.isTempUser = true
            }
        }
    }
    
    func handleOldBeaconList() {
        if UserDefaults.standard.orgBeaconListV2 == nil && UserDefaults.standard.orgBeaconList != nil {
            let oldList = UserDefaults.standard.orgBeaconList!
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom({ (date) -> Date in
                let container = try date.singleValueContainer()
                var dateStr = try container.decode(String.self)
                dateStr = dateStr.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                return dateFormatter.date(from: dateStr) ?? Date(timeIntervalSince1970: 0)
            })
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: oldList, options: JSONSerialization.WritingOptions.prettyPrinted)
                let bl = try decoder.decode(BeaconList.self, from: jsonData)
                UserDefaults.standard.orgBeaconListV2 = bl
                UserDefaults.standard.orgBeaconList = nil //clear forever
            } catch let err as NSError {
                print(err)
                logService.error(message: "Could not parse old beacon list into new list")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        appService.stop()
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        logService.info(message: "App paused")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        logService.info(message: "App resuming")
        NavigationManager.shared.resume()
        GivtManager.shared.resume()
        NotificationManager.shared.resume()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        LoginManager.shared.resume()
        appService.start()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        logService.info(message: "App is terminating")
        appService.stop()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        //
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb { //coming from safari
            if let appScheme = GivtManager.shared.externalIntegration?.appScheme {
                let url = URL(string: appScheme)!
                if NavigationHelper.openUrl(url: url, completion: nil) {
                    LogService.shared.info(message: "User just gave, coming back to Givt, now going to \(appScheme)")
                } else {
                    LogService.shared.warning(message: "\(url) was not installed on the device.")
                }
            } else if let url = userActivity.webpageURL{
                if let mediumId = GivtManager.shared.getMediumIdFromGivtLink(link: url.absoluteString) {
                    if mediumId.count < 20 || GivtManager.shared.getOrganisationName(organisationNameSpace: String(mediumId.prefix(20))) == nil {
                        LogService.shared.warning(message: "Illegal mediumid \"\(mediumId)\" provided. Going to normal give flow")
                    } else {
                        let specialChar = mediumId.substring(21..<22)
                        if (specialChar == "c"){
                            GivtManager.shared.externalIntegration = ExternalAppIntegration(mediumId: mediumId, name: "QR", logo: UIImage(named: "qr_scan_phone"))
                        } else {
                            GivtManager.shared.externalIntegration = ExternalAppIntegration(mediumId: mediumId)
                        }
                        LogService.shared.info(message: "App scheme: QR entering Givt-app with identifier \(mediumId)")
                        return true;
                    }
                }
            }
            GivtManager.shared.externalIntegration = nil
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let host = url.host, host == "sharemygivt" {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                var message = NSLocalizedString("ShareTheGivtTextNoOrg", comment: "")
                if let namespace = UserDefaults.standard.lastGivtToOrganisationNamespace, let organisation = GivtManager.shared.getOrganisationName(organisationNameSpace: namespace) {
                    message = NSLocalizedString("ShareTheGivtText", comment: "").replacingOccurrences(of: "{0}", with: organisation)
                }

                message += " " + NSLocalizedString("JoinGivt", comment: "")
                let activityViewController = UIActivityViewController(activityItems: [message as NSString], applicationActivities: nil)
                topController.present(activityViewController, animated: true, completion: nil)
                logService.info(message: "A Givt is being shared via the Safari-flow")
            }
        } else {
            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems {
                if let mediumIdValue = queryItems.first(where: { (item) -> Bool in item.name.lowercased() == "mediumid" })?.value {
                    if mediumIdValue.count < 20 || GivtManager.shared.getOrganisationName(organisationNameSpace: String(mediumIdValue.prefix(20))) == nil {
                        LogService.shared.warning(message: "Illegal mediumid \"\(mediumIdValue)\" provided. Going to normal give flow")
                    } else {
                        if let fromValue = queryItems.first(where: { (item) -> Bool in item.name.lowercased() == "from" })?.value {
                            if let appId = queryItems.first(where: { (item) -> Bool in item.name.lowercased() == "appid" })?.value,
                                let element = AppConstants.externalApps[appId], let name = element["name"] {
                                    var image: UIImage? = nil
                                    if let imageString = element["logo"] {
                                        image = UIImage(named: imageString)
                                    }
                                    GivtManager.shared.externalIntegration = ExternalAppIntegration(mediumId: mediumIdValue, name: name, logo: image, appScheme: fromValue)
                            } else {
                                GivtManager.shared.externalIntegration = ExternalAppIntegration(mediumId: mediumIdValue, appScheme: fromValue)
                            }
                        } else {
                            GivtManager.shared.externalIntegration = ExternalAppIntegration(mediumId: mediumIdValue)
                        }
                        LogService.shared.info(message: "Entering Givt-app with identifier \(mediumIdValue)")
                    }
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.processRegisterForRemoteNotifications(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification pushNotificationInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void ) {
        NotificationManager.shared.processPushNotification(fetchCompletionHandler: completionHandler, pushNotificationInfo: pushNotificationInfo)
    }
    
    func registerHandlers() {
        Mediater.shared.registerHandler(handler: GetCollectGroupsQueryHandler())
        Mediater.shared.registerHandler(handler: GetLocalUserConfigurationHandler())
        Mediater.shared.registerHandler(handler: OpenChooseAmountRouteHandler())
        Mediater.shared.registerHandler(handler: BackToChooseDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: BackToMainRouteHandler())
        Mediater.shared.registerHandler(handler: ChangeAmountLimitRouteHandler())
        Mediater.shared.registerHandler(handler: CreateDonationCommandHandler())
        Mediater.shared.registerPreProcessor(processor: ChangeAmountLimitRoutePreHandler())
        Mediater.shared.registerPreProcessor(processor: CreateDonationCommandValidator())
        Mediater.shared.registerHandler(handler: DeleteDonationCommandHandler())
        Mediater.shared.registerHandler(handler: ExportDonationCommandHandler())
        Mediater.shared.registerHandler(handler: GoToSafariRouteHandler())
        Mediater.shared.registerHandler(handler: FinalizeGivingRouteHandler())
        Mediater.shared.registerHandler(handler: NoInternetAlertHandler())
        Mediater.shared.registerHandler(handler: GetRecurringDonationsQueryHandler())
        
        // Flow: SetupRecurringDonation
        // -- Navigation
        Mediater.shared.registerHandler(handler: DestinationSelectedRouteHandler())
        Mediater.shared.registerHandler(handler: SetupRecurringDonationChooseDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: GoToChooseRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: BackToSetupRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: PopToRecurringDonationOverviewRouteHandler())
        Mediater.shared.registerHandler(handler: BackToRecurringDonationOverviewRouteHandler())

        // -- Commands
        Mediater.shared.registerPreProcessor(processor: CreateRecurringDonationCommandPreHandler())
        Mediater.shared.registerHandler(handler: CreateRecurringDonationCommandHandler())
        Mediater.shared.registerPostProcessor(processor: CreateRecurringDonationCommandPostHandler())
        
        Mediater.shared.registerHandler(handler: CancelRecurringDonationCommandHandler())
    }
}
