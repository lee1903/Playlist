//
//  AppDelegate.swift
//  Playlist
//
//  Created by Brian Lee on 3/11/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit
import PYSearch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    
    let clientID = "b9e60d3ffe6e4df8bbab4267ee07470f"
    let callbackURL = "playlist://returnafterlogin"
    let tokenSwapURL = "http://localhost:1235/swap"
    let tokenRefreshServiceURL = "http://localhost:1235/refresh"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.displayPlayerView), name: NSNotification.Name(rawValue: "createPlaylistSessionSuccessful"), object: nil)
        
        if !SpotifyClient.sharedInstance.authenticateSpotifySession() {
            print("user needs to login")
            let vc = storyboard.instantiateViewController(withIdentifier: "SpotifyLoginViewController")
            window?.rootViewController = vc
        } else if PlaylistSessionManager.sharedInstance.hasSession() {
            print("has playlist session")
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "CreateJoinSessionNavController")
            window?.rootViewController = vc
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if SPTAuth.defaultInstance().canHandle(url) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                if error != nil {
                    print("authentication error")
                    print(error!)
                    return
                }
                
                let userDefaults = UserDefaults.standard
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session as Any)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                
                SpotifyClient.sharedInstance.authenticateSpotifySession()
                
                self.userDidLogin()
            })
        }
        
        return false
    }
    
    func userDidLogin() {
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateJoinSessionNavController")
        window?.rootViewController = vc
    }
    
    func displayPlayerView() {
        let vc = storyboard.instantiateInitialViewController()
        window?.rootViewController = vc
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


}

