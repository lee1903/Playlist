//
//  PlaylistSessionManager.swift
//  Playlist
//
//  Created by Brian Lee on 3/20/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class PlaylistSessionManager {
    
    var session: PlaylistSession?
    
    class var sharedInstance: PlaylistSessionManager {
        struct Static {
            static let instance = PlaylistSessionManager()
        }
        return Static.instance
    }
    
    func hasSession() -> Bool {
        let userDefaults = UserDefaults.standard
        if let sessionObj:Any = userDefaults.object(forKey: "PlaylistSession") {
            print("playlist session available")
            
            let playlistDataObj = sessionObj as! Data
            self.session = NSKeyedUnarchiver.unarchiveObject(with: playlistDataObj) as! PlaylistSession
            
            return true
        } else {
            return false
        }
    }
    
    func saveSession(session: PlaylistSession, completion:@escaping () -> ()) {
        let userDefaults = UserDefaults.standard
        let sessionData = NSKeyedArchiver.archivedData(withRootObject: session as Any)
        userDefaults.set(sessionData, forKey: "PlaylistSession")
        userDefaults.synchronize()
        
        self.session = session
        
        completion()
    }
}
