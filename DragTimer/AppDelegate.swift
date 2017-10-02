//
//  AppDelegate.swift
//  DragTimer
//
//  Created by Philipp Matthes on 07.08.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var customizedLaunchScreenView: UIView?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge], categories: nil))
        
//        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-5941274384378366~3686328024")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        pushNotification()
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
    
//    func pushNotification() {
//        let notification = UILocalNotification()
//        notification.alertAction = "Go back to the DragTimer App"
//        notification.alertBody = "Goodbye! The app will not track your speed when closed."
//        notification.fireDate = NSDate(timeIntervalSinceNow: 10) as Date
//        UIApplication.shared.scheduleLocalNotification(notification)
//    }


}

