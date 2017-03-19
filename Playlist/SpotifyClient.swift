//
//  SpotifyClient.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class SpotifyClient: NSObject {
    let clientID = "b9e60d3ffe6e4df8bbab4267ee07470f"
    let callbackURL = "playlist://returnafterlogin"
    let tokenSwapURL = "http://localhost:1235/swap"
    let tokenRefreshServiceURL = "http://localhost:1235/refresh"
    
    var session: SPTSession!
    
    let userDefaults = UserDefaults.standard
    
    class var sharedInstance: SpotifyClient {
        struct Static {
            static let instance = SpotifyClient()
        }
        return Static.instance
    }
    
    func authenticateSpotifySession() -> Bool {
        if let sessionObj:Any = userDefaults.object(forKey: "SpotifySession") {
            print("spotify session available")
            
            let sessionDataObj = sessionObj as! Data
            self.session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
       
            return validateSpotifySession(session: self.session)
        } else {
            //self.promptUserLogin()
            return false
        }
    }
    
    func validateSpotifySession(session: SPTSession) -> Bool {
        var returnValue = false
        
        if !session.isValid() {
            SPTAuth.defaultInstance().renewSession(session, callback: { (error, renewedSession) in
                if error != nil {
                    print("error refreshing session")
                    print(error)
                    //self.promptUserLogin()
                    returnValue = false
                } else {
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: renewedSession as Any)
                    self.userDefaults.set(sessionData, forKey: "SpotifySession")
                    self.userDefaults.synchronize()
                    
                    self.session = renewedSession
                    //self.playUsingSession(sessionObj: session)
                    returnValue = true
                }
            })
        } else {
            print("session valid")
            //self.playUsingSession(sessionObj: session)
            return true
        }
        
        return returnValue
    }
}
