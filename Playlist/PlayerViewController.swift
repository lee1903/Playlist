//
//  ViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/11/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    let clientID = "b9e60d3ffe6e4df8bbab4267ee07470f"
    let callbackURL = "playlist://returnafterlogin"
    let tokenSwapURL = "http://localhost:1235/swap"
    let tokenRefreshServiceURL = "http://localhost:1235/refresh"
    
    var session: SPTSession!
    var player: SPTAudioStreamingController?
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.session = SpotifyClient.sharedInstance.session
        self.playUsingSession(sessionObj: self.session)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //authenticateSpotifySession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onStartPlaying(_ sender: Any) {
        if (PlaylistSessionManager.sharedInstance.session?.tracklist.count)! > 0 {
            let currentTrack = PlaylistSessionManager.sharedInstance.session!.tracklist[0]
            self.playSong(spotifyURI: currentTrack.playableURI.absoluteString)
     
        }
    }
}

extension PlayerViewController: SPTAudioStreamingDelegate {
    
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
    }
    
    func playSong(spotifyURI: String) {
        player?.playSpotifyURI(spotifyURI, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if error != nil {
                print("error playing uri")
                print(error)
            }
        })
    }
}
