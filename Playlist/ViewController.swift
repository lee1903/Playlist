//
//  ViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/11/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAudioStreamingDelegate {
    
    let clientID = "b9e60d3ffe6e4df8bbab4267ee07470f"
    let callbackURL = "playlist://returnafterlogin"
    let tokenSwapURL = "http://localhost:1235/swap"
    let tokenRefreshServiceURL = "http://localhost:1235/refresh"
    
    var session: SPTSession!
    var player: SPTAudioStreamingController?

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:Any = userDefaults.object(forKey: "SpotifySession") {
            print("spotify session available")
            
            let sessionDataObj = sessionObj as! Data
            let session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            if !session.isValid() {
                SPTAuth.defaultInstance().renewSession(session, callback: { (error, renewedSession) in
                    if error != nil {
                        print("error refreshing session")
                        print(error)
                    } else {
                        let sessionData = NSKeyedArchiver.archivedData(withRootObject: renewedSession as Any)
                        userDefaults.set(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        self.session = renewedSession
                        self.playUsingSession(sessionObj: session)
                    }
                })
            } else {
                print("session valid")
                self.playUsingSession(sessionObj: session)
            }
            
        } else {
            loginButton.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAfterFirstLogin() {
        loginButton.isHidden = true
    }
    
    func playUsingSession(sessionObj: SPTSession!) {
        if player == nil {
            print("setting player")
            player = SPTAudioStreamingController.sharedInstance()
            do {
                try player?.start(withClientId: clientID)
            } catch {
                print(error)
            }
            player?.delegate = self
            print("player set successfully")
        } else {
            print("player already set")
        }
        
        
        player?.login(withAccessToken: sessionObj.accessToken)
        print("logging in with access token")
        
    }
    
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("audio stream reconnected")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print(message)
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("audio stream logged in")
        player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if error != nil {
                print("error playing uri")
                print(error)
            }
        })
    }


    @IBAction func onLoginWithSpotify(_ sender: Any) {
        let auth = SPTAuth.defaultInstance()
        
        auth?.clientID = clientID
        auth?.requestedScopes = [SPTAuthStreamingScope]
        auth?.redirectURL = URL(string: callbackURL)
        auth?.tokenSwapURL = URL(string: tokenSwapURL)
        auth?.tokenRefreshURL = URL(string: tokenRefreshServiceURL)
        
        UIApplication.shared.openURL((auth?.spotifyWebAuthenticationURL())!)
    }
    
}

