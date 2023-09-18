
import UIKit
import CoreData
import SwiftyStoreKit
import Adjust
import GameAnalytics
import AppLovinSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, AdjustDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ALSdk.shared()!.settings.testDeviceAdvertisingIdentifiers = ["\(UIDevice.current.identifierForVendor?.uuidString ?? "")"]
        
        ALSdk.shared()!.mediationProvider = ALMediationProviderMAX
        
        ALSdk.shared()!.initializeSdk { (configuration: ALSdkConfiguration) in
            let appToken = "ptrpxwo1e2o0"
            let environment = ADJEnvironmentProduction
            let adjustConfig = ADJConfig(appToken: appToken, environment: environment)
            adjustConfig?.logLevel = ADJLogLevelVerbose
            adjustConfig?.delegate = self
            Adjust.appDidLaunch(adjustConfig)
            // Start loading ads
        }
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        GameAnalytics.setEnabledInfoLog(true)
        GameAnalytics.setEnabledVerboseLog(true)
        GameAnalytics.configureBuild(appVersion)
        GameAnalytics.initialize(withGameKey: "e7fd25588b12f02444ee49df0d8dc321", gameSecret: "4436a0198912eb9240fda2386d1d88e76277acd8")
        
        GameAnalytics.configureAvailableResourceCurrencies(["gems", "gold"])
        GameAnalytics.configureAvailableResourceItemTypes(["boost", "lives"])
        // Set available custom dimensions
        GameAnalytics.configureAvailableCustomDimensions01(["ninja", "samurai"])
        GameAnalytics.configureAvailableCustomDimensions02(["whale", "dolphin"])
        GameAnalytics.configureAvailableCustomDimensions03(["horde", "alliance"])
       
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        self.goToScreen()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            if granted {
                print("Notification Enable Successfully")
            }else{
                print("Some Error Occure")
            }
        }
        application.registerForRemoteNotifications()
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                    // Unlock content
                case .failed:
                    print("=======================FAILED===========================")
                    break
                case .purchasing:
                    print("=======================PURCHAISNG===========================")
                    break
                case .deferred:
                    print("=======================DEFFERED============================")
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
        self.checkIAPStatus()
        return true
    }
    
    func goToScreen() {
        
        if let isOpen = UserDefaults.standard.value(forKey: "isOpen") as? Bool {
            if isOpen {
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                let navigationController = UINavigationController(rootViewController: newViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            } else {
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "AppGuideVC") as! AppGuideVC
                let navigationController = UINavigationController(rootViewController: newViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }
            
        } else {
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "AppGuideVC") as! AppGuideVC
            let navigationController = UINavigationController(rootViewController: newViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        
    }
    
    func checkIAPStatus() {
        
        if checkReward() {
            setWeeklyPurchased(bool: false)
            serverTimeReturn { getResDate in
                if getResDate != "" , let serverDate = convertStringToDateReward(str: getResDate) {
                    if getRewardDate() != "" , let rewardDate = convertStringToDateReward(str: getRewardDate()) {
                        let diffComponents = Calendar.current.dateComponents([.hour], from: rewardDate, to: serverDate)
                        if diffComponents.hour ?? 0 > 1 {
                            let defaults = UserDefaults(suiteName: groupID)
                            defaults?.set(false, forKey: "get_reward")
                            defaults?.synchronize()
                            setWeeklyPurchased(bool: false)
                            print(false)
                        } else {
                            setWeeklyPurchased(bool: true)
                            print(true)
                        }
                    }
                    
                }
            }
            
        } else {
            IAPHelper.checkPurchaseStatus(productId: weekly_id) { errorStr, expiryDate, isSuccess in
                if isSuccess, let eDate = expiryDate {
                    if isSuccess {
                        setWeeklyPurchased(bool: true)
                        setIAPStartDate(date: Date())
                        setIAPExpiryDate(date: eDate)
                    } else {
                        print(errorStr ?? "")
                        setWeeklyPurchased(bool: false)
                    }
                } else {
                    print(errorStr ?? "")
                    setWeeklyPurchased(bool: false)
                }
            }
        }
        
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("open")
        let urlPath : String = url.absoluteString
        print(urlPath)
        if urlPath.contains("subscription") {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
            vc.modalPresentationStyle = .fullScreen
            initialViewController.present(vc, animated: true, completion: nil)
        } else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            let vc = storyBoard.instantiateViewController(withIdentifier: "KeyboardGuidlineVC") as! KeyboardGuidlineVC
            vc.modalPresentationStyle = .fullScreen
            initialViewController.present(vc, animated: true, completion: nil)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?) {
        
    }
    
    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
        
    }
    
    func adjustSessionTrackingSucceeded(_sessionSuccessResponseData: ADJSessionSuccess) {
        
    }
    
    func adjustSessionTrackingFailed(_sessionFailureResponseData: ADJSessionFailure) {
        
    }
    
}
