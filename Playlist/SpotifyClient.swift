//
//  SpotifyClient.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation
import AFNetworking

class SpotifyClient {
    let clientID = "b9e60d3ffe6e4df8bbab4267ee07470f"
    let callbackURL = "playlist://returnafterlogin"
//    let tokenSwapURL = "http://localhost:1235/swap"
//    let tokenRefreshServiceURL = "http://localhost:1235/refresh"
    let tokenSwapURL = "https://strawberry-pudding-60129.herokuapp.com/swap"
    let tokenRefreshServiceURL = "https://strawberry-pudding-60129.herokuapp.com/refresh"
    
    var session: SPTSession!
    var currentUser: User!
    
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
                    print(error!)
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
            self.setSpotifyUser()
            return true
        }
        
        return returnValue
    }
    
    @objc private func setSpotifyUser() {
        if let userObj:Any = userDefaults.object(forKey: "user") {
            print("user data available")
            
            let userDataObj = userObj as! Data
            self.currentUser = NSKeyedUnarchiver.unarchiveObject(with: userDataObj) as! User
            
            print(self.currentUser.name)
            print(self.currentUser.id)
            
        } else {
            self.getSpotifyUser(completion: { (user, error) in
                if error != nil {
                    print(error!)
                } else {
                    if user != nil{
                        self.currentUser = user
                        
                        print(self.currentUser.name)
                        print(self.currentUser.id)
                        
                        let userData = NSKeyedArchiver.archivedData(withRootObject: user as Any)
                        self.userDefaults.set(userData, forKey: "user")
                        self.userDefaults.synchronize()
                        
                        print("successfully set user")
                    } else {
                        print("recursively calling self to get user display name")
                        self.setSpotifyUser()
                    }
                }
            })
        }
    }
    
    private func getSpotifyUser(completion:@escaping (User?, Error?) -> ()) {
        let url = "https://api.spotify.com/v1/me"
        
        let token = String(format: "Bearer %@", session.accessToken)
        
        let manager = AFHTTPSessionManager(baseURL: URL(string: url))
        
        manager.requestSerializer.setValue(token, forHTTPHeaderField: "Authorization")
        manager.get(url, parameters: [], progress: { (progress) in }, success: { (dataTask: URLSessionDataTask, response: Any?) in
            
            let resDictionary = response! as! NSDictionary
            
            print(resDictionary)
            
            if let name = resDictionary["display_name"] as? String {
                let id = resDictionary["id"] as! String
                
                let user = User(name: name, id: id)
                
                completion(user, nil)
            } else {
                print("error retrieving user info from spotify")
                completion(nil, nil)
            }
            
            
        }) { (dataTask: URLSessionDataTask?, error: Error) in
            completion(nil, error)
        }
    }
}
