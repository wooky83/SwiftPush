//
//  AppDelegate.swift
//  SwiftPush
//
//  Created by 1002659 on 24/07/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let categoryButtonsId = "AcceptOrReject"
    enum ActionButtonsId: String {
        case accept, reject
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let nm = UserDefaults.standard.value(forKey: "key") as? Int {
            print("Slient Data is \(nm)")
        }
        registerForPushNotifications(application: application)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        print(token)
        registerCustomActions()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification")
        guard let nb = userInfo["number"] as? Int else {
            completionHandler(.noData)
            return
        }
        print("Silent Push!! : \(nb)")
        UserDefaults.standard.set(nb, forKey: "key")
        UserDefaults.standard.synchronize()
        completionHandler(.newData)
        //completionHandler(.failed)
    }
    
}

extension AppDelegate {
    func registerForPushNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) {
            [weak self] granted, _ in
            guard granted else { return }
            
            center.delegate = self
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func registerCustomActions() {
        // Buttons category
        let accept = UNNotificationAction(identifier: ActionButtonsId.accept.rawValue, title: "Accept")
        let reject = UNNotificationAction(identifier: ActionButtonsId.reject.rawValue, title: "Reject")
        let categoryButtons = UNNotificationCategory(identifier: categoryButtonsId, actions: [accept, reject], intentIdentifiers: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([categoryButtons])
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    //포그라운드에서 푸쉬 수신 이벤트
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent notification")
        //completionHandler 호출안하면 alert 안뜸
        completionHandler([.alert, .sound, .badge])
    }
    //backGround Push 받을때 이벤트
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        print("didReceive response")
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let payload = response.notification.request.content
            print(String(describing: payload))
            guard let _ = payload.userInfo["otterspot"] else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "otterspot")
            self.window!.rootViewController!.present(vc, animated: false)
        }
        
        let identity = response.notification.request.content.categoryIdentifier
        guard identity == categoryButtonsId, let action = ActionButtonsId(rawValue: response.actionIdentifier) else { return }
        print("You pressed \(response.actionIdentifier)")
        let userInfo = response.notification.request.content.userInfo
        switch action {
        case .accept:
            Notification.Name.acceptButton.post(userInfo: userInfo)
        case .reject:
            Notification.Name.rejectButton.post(userInfo: userInfo)
        }
        
    }
    
}
