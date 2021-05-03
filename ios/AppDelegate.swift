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
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, UNUserNotificationCenterDelegate, NotificationRecurringDonationTurnCreatedDelegate, NotificationShowFeatureUpdateDelegate, NotificationOpenSummaryDelegate {
    
    var window: UIWindow?
    var logService: LogService = LogService.shared
    var appService: AppServices = AppServices.shared
    
    var loginManager: LoginManager = LoginManager.shared
    
    var mixpanel: MixpanelInstance = Mixpanel.initialize(token: AppConstants.mixpanelProjectId)
    
    var coreDataContext = CoreDataContext()
        
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        NotificationManager.shared.delegates.append(self)

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            if let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification], let pushNotificationInfo = remoteNotif as? [AnyHashable : Any] {
                DispatchQueue.global(qos: .background).async {
                    NotificationManager.shared.processPushNotification(fetchCompletionHandler: {result in }, pushNotificationInfo: pushNotificationInfo )
                }
            }
        }
        
        handleOldBeaconList()
        checkIfTempUser()
        doMagicForPresets()
        
        mixpanel.serverURL = "https://api-eu.mixpanel.com"
        
        if #available(iOS 10.0, *) {
            setupNotifications()
        }
        
        return true
    }
    
    @available(iOS 10.0, *)
    func setupNotifications() {
        var dateComponents: DateComponents?
        #if PRODUCTION
        dateComponents = DateComponents(
            calendar: Calendar.current,
            day: 25,
            hour: 20
        )
        #else
        dateComponents = DateComponents(
            calendar: Calendar.current,
            second: 30
        )
        #endif
        
        let localNotificationManager = LocalNotificationManager.shared
        
        localNotificationManager.notifications = [
            LocalNotification(
                id: "TestOne",
                title: "BudgetPushMonthlyBold".localized,
                subTitle: "BudgetPushMonthly".localized,
                dateTime: dateComponents!,
                userInfo: ["Type" : NotificationType.OpenSummaryNotification.rawValue],
                shouldRepeat: true
            )
        ]
        if !UserDefaults.standard.isTempUser {
            localNotificationManager.schedule()
        }
    }
    func onReceivedRecurringDonationTurnCreated(recurringDonationId: String) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            guard let mainViewController = window.rootViewController?.children
                    .first(where: { (child) -> Bool in child is MainNavigationController })?.children
                    .first(where: { (child) -> Bool in child is MainViewController }) else { return }
            
            if let prentedViewcontroller = mainViewController.children.first?.presentedViewController {
                prentedViewcontroller.dismiss(animated: true, completion: nil)
            }
            
            try? Mediater.shared.sendAsync(request: OpenRecurringRuleDetailFromNotificationRoute(recurringDonationId: recurringDonationId), withContext: mainViewController) { }
        }
    }
    
    func onReceiveShowFeatureUpdate(featureId: Int) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            guard let mainViewController = window.rootViewController?.children
                    .first(where: { (child) -> Bool in child is MainNavigationController })?.children
                    .first(where: { (child) -> Bool in child is MainViewController }) else { return }
            
            if let prentedViewcontroller = mainViewController.children.first?.presentedViewController {
                prentedViewcontroller.dismiss(animated: true, completion: nil)
            }
            
            if FeatureManager.shared.highestFeature >= featureId {
                try? Mediater.shared.sendAsync(request: OpenFeatureByIdRoute(featureId: featureId), withContext: mainViewController) { }
            } else {
                try? Mediater.shared.sendAsync(request: ShowUpdateAlert(), withContext: mainViewController) { }
            }
        }
    }

    func onReceiveOpenSummaryNotification() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            guard let mainViewController = window.rootViewController?.children
                    .first(where: { (child) -> Bool in child is MainNavigationController })?.children
                    .first(where: { (child) -> Bool in child is MainViewController }) else { return }
            
            if let prentedViewcontroller = mainViewController.children.first?.presentedViewController {
                prentedViewcontroller.dismiss(animated: true, completion: nil)
            }
            
            if !AppServices.shared.isServerReachable {
                try? Mediater.shared.send(request: NoInternetAlert(), withContext: mainViewController)
            }
            
            try? Mediater.shared.sendAsync(request: OpenSummaryRoute(), withContext: mainViewController) { }
        }
    }
    func doMagicForPresets() {
        if(UserDefaults.standard.object(forKey: UserDefaults.UserDefaultsKeys.presetsSet.rawValue) == nil){
            UserDefaults.standard.hasPresetsSet = UserDefaults.standard.userExt?.guid != nil
        }
    }
    
    func checkIfTempUser() {
        guard let userExt = UserDefaults.standard.userExt else {
            UserDefaults.standard.isTempUser = true
            return
        }
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
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb { //coming from safari
            GivtManager.shared.externalIntegration = nil
            if let appScheme = GivtManager.shared.externalIntegration?.appScheme {
                let url = URL(string: appScheme)!
                if NavigationHelper.openUrl(url: url, completion: nil) {
                    LogService.shared.info(message: "User just gave, coming back to Givt, now going to \(appScheme)")
                } else {
                    LogService.shared.warning(message: "\(url) was not installed on the device.")
                }
            } else if let url = userActivity.webpageURL {
                if let mediumId = GivtManager.shared.getMediumIdFromGivtLink(link: url.absoluteString) {
                    if mediumId.count < 20 || GivtManager.shared.getOrganisationName(organisationNameSpace: String(mediumId.prefix(20))) == nil {
                        LogService.shared.warning(message: "Illegal mediumid \"\(mediumId)\" provided. Going to normal give flow")
                    } else {
                        let specialChar = mediumId.substring(21..<22)
                        if (specialChar == "c") {
                            GivtManager.shared.externalIntegration = ExternalAppIntegration(mediumId: mediumId, name: "QR", logo: UIImage(named: "qr_scan_phone"))
                        } else {
                            GivtManager.shared.externalIntegration = ExternalAppIntegration(mediumId: mediumId)
                        }
                        LogService.shared.info(message: "App scheme: QR entering Givt-app with identifier \(mediumId)")
                        return true;
                    }
                }
            }
        }
        return true
    }

    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
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
            guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = urlComponents.queryItems,
                  let mediumIdValue = queryItems.first(where: { (item) -> Bool in item.name.lowercased() == "mediumid" })?.value
            else { return true }
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
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.processRegisterForRemoteNotifications(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //background
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let pushNotificationInfo = response.notification.request.content.userInfo
            DispatchQueue.global(qos: .background).async {
                NotificationManager.shared.processPushNotification(fetchCompletionHandler: {result in }, pushNotificationInfo: pushNotificationInfo )
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //foreground
        let userInfo = notification.request.content.userInfo
                print(userInfo) // the payload that is attached to the push notification
                // you can customize the notification presentation options. Below code will show notification banner as well as play a sound. If you want to add a badge too, add .badge in the array.
                completionHandler([.alert,.sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification pushNotificationInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void ) {
        //voorgrond
        
//        NotificationManager.shared.processPushNotification(fetchCompletionHandler: completionHandler, pushNotificationInfo: pushNotificationInfo)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = self.window
        
        guard let userActivity = connectionOptions.userActivities.first else { return }
        let _ = application(UIApplication.shared, continue: userActivity) { (_) in }
    }

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        let _ = application(UIApplication.shared, continue: userActivity) { (_) in }
    }
    
    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        let _ = applicationDidBecomeActive(UIApplication.shared)
    }
    
    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        let _ = applicationWillResignActive(UIApplication.shared)
    }
    
    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        let _ = applicationDidEnterBackground(UIApplication.shared)
    }
    
    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        let _ = applicationWillEnterForeground(UIApplication.shared)
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            let _ = application(UIApplication.shared, open: urlContext.url)
        }
    }
    
    func registerHandlers() {
        // -- DONATIONS
        Mediater.shared.registerHandler(handler: CreateDonationCommandHandler())
        Mediater.shared.registerPreProcessor(processor: CreateDonationCommandValidator())
        Mediater.shared.registerHandler(handler: DeleteDonationCommandHandler())
        Mediater.shared.registerHandler(handler: ExportDonationCommandHandler())
        Mediater.shared.registerHandler(handler: GetDonationsByIdsQueryHandler())
        // -- RECURRING DONATIONS
        Mediater.shared.registerHandler(handler: GetRecurringDonationsQueryHandler())
        Mediater.shared.registerPreProcessor(processor: CreateRecurringDonationCommandPreHandler())
        Mediater.shared.registerHandler(handler: CreateRecurringDonationCommandHandler())
        Mediater.shared.registerHandler(handler: CancelRecurringDonationCommandHandler())
        Mediater.shared.registerHandler(handler: GetRecurringDonationTurnsQueryHandler())
        //-- USER QUERIES
        Mediater.shared.registerHandler(handler: GetLocalUserConfigurationHandler())
        Mediater.shared.registerHandler(handler: GetCountryQueryHandler())
        
        // -- COLLECT GROUPS
        Mediater.shared.registerHandler(handler: GetCollectGroupsQueryHandler())
        Mediater.shared.registerPreProcessor(processor: GetCollectGroupsQueryPreProcessor())
        
        // -- NAVIGATION
        Mediater.shared.registerHandler(handler: BackToMainRouteHandler())
        Mediater.shared.registerHandler(handler: FinalizeGivingRouteHandler())
        Mediater.shared.registerHandler(handler: DestinationSelectedRouteHandler())
        Mediater.shared.registerHandler(handler: SetupRecurringDonationChooseDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: GoToChooseRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: BackToSetupRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: PopToRecurringDonationOverviewRouteHandler())
        Mediater.shared.registerHandler(handler: BackToRecurringDonationOverviewRouteHandler())
        Mediater.shared.registerHandler(handler: GoToPushNotificationViewRouteHandler())
        Mediater.shared.registerHandler(handler: DismissPushNotificationViewRouteHandler())
        Mediater.shared.registerHandler(handler: GoToAboutViewRouteHandler())
        Mediater.shared.registerHandler(handler: OpenRecurringDonationOverviewListRouteHandler())
        Mediater.shared.registerHandler(handler: OpenRecurringRuleDetailFromNotificationRouteHandler())
        
        //-- INFRA
        Mediater.shared.registerHandler(handler: NoInternetAlertHandler())
        Mediater.shared.registerHandler(handler: GoBackOneControllerRouteHandler())
        Mediater.shared.registerHandler(handler: OpenFeatureByIdRouteHandler())
        Mediater.shared.registerHandler(handler: ShowUpdateAlertHandler())

        //-- DISCOVER OR AMOUNT: ROUTES
        Mediater.shared.registerHandler(handler: BackToMainViewRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenSelectDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenSetupSingleDonationRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenSetupRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenSafariRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountBackToSelectDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenChangeAmountLimitRouteHandler())
        Mediater.shared.registerPreProcessor(processor: DiscoverOrAmountOpenChangeAmountLimitRoutePreHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenRecurringSuccessRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenOfflineSuccessRouteHandler())
        Mediater.shared.registerHandler(handler: GetAllDonationsQueryHandler())
        
        //-- BUDGET SCENE: ROUTES
        Mediater.shared.registerHandler(handler: OpenSummaryRouteHandler())
        Mediater.shared.registerHandler(handler: OpenGiveNowRouteHandler())
        Mediater.shared.registerHandler(handler: OpenExternalGivtsRouteHandler())
        //-- BUDGET SCENE: QUERYS
        Mediater.shared.registerHandler(handler: GetMonthlySummaryQueryHandler())
                    
        //-- Budget External Donation Create
        Mediater.shared.registerHandler(handler: CreateExternalDonationCommandHandler())
        Mediater.shared.registerPreProcessor(processor: CreateExternalDonationCronGenerator())
        
        //-- Budget External Donation Update
        Mediater.shared.registerHandler(handler: UpdateExternalDonationCommandHandler())
        
        //-- Budget External Donation Delete
        Mediater.shared.registerHandler(handler: DeleteExternalDonationCommandHandler())
        
        //-- Budget External Donation GetAll
        Mediater.shared.registerHandler(handler: GetAllExternalDonationsQueryHandler())
        
        //-- Budget External Donation Summary
        Mediater.shared.registerHandler(handler: GetExternalMonthlySummaryQueryHandler())
    }
}
