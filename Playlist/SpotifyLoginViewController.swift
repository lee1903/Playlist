//
//  SpotifyLoginViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/12/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class SpotifyLoginViewController: UIViewController {
    
    let clientID = "b9e60d3ffe6e4df8bbab4267ee07470f"
    let callbackURL = "playlist://returnafterlogin"
//    let tokenSwapURL = "http://localhost:1235/swap"
//    let tokenRefreshServiceURL = "http://localhost:1235/refresh"
    let tokenSwapURL = "https://strawberry-pudding-60129.herokuapp.com/swap"
    let tokenRefreshServiceURL = "https://strawberry-pudding-60129.herokuapp.com/refresh"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAfterLogin() {
        self.dismiss(animated: true) { 
            print("successful login in spotifyloginviewcontroller")
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let auth = SPTAuth.defaultInstance()
        
        auth?.clientID = clientID
        auth?.requestedScopes = [SPTAuthStreamingScope]
        auth?.redirectURL = URL(string: callbackURL)
        auth?.tokenSwapURL = URL(string: tokenSwapURL)
        auth?.tokenRefreshURL = URL(string: tokenRefreshServiceURL)
        
        UIApplication.shared.openURL((auth?.spotifyWebAuthenticationURL())!)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
