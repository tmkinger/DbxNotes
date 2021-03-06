//
//  AppDelegate.swift
//  DBXNotes
//
//  Created by Tarun Mukesh Kinger on 17/03/18.
//  Copyright © 2018 Tarun Mukesh Kinger. All rights reserved.
//

import UIKit
import SwiftyDropbox

let kDropBoxAppKey = "95586y1ni77xejg"
let kLoggedInNotificationKey = "loggedIn"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DropboxClientsManager.setupWithAppKey(kDropBoxAppKey)
        if (DropboxClientsManager.authorizedClient != nil) {
            //User is already authorized
            NotificationCenter.default.post(name: Notification.Name(kLoggedInNotificationKey), object: nil, userInfo: nil)
        }
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
        self.clearDocumentsDirectory()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("User is logged into Dropbox.")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(kLoggedInNotificationKey), object: nil, userInfo: nil)
                }
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }
        return true
    }
    
    //clear the documents directory when the app is terminated
    func clearDocumentsDirectory() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
}

