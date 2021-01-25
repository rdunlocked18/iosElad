//
//  AppDelegate.swift
//  EladTraining
//
//  Created by Rohit Daftari on 07/12/20.
//

import UIKit
import Firebase
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Ask permission for notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied\n")
            }
        }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("entered in background")
        completionHandler()
    }
    
//    fileprivate func showLocalNotification() {
//
//        //creating the notification content
//        let content = UNMutableNotificationContent()
//
//        //adding title, subtitle, body and badge
//        content.title = "App Update"
//        //content.subtitle = "local notification"
//        content.body = "New version of app update is available."
//        //content.badge = 1
//        content.sound = UNNotificationSound.default
//
//        //getting the notification trigger
//        //it will be called after 5 seconds
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//
//        //getting the notification request
//        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
//
//        //adding the notification to notification center
//        notificationCenter.add(request, withCompletionHandler: nil)
//    }


}

