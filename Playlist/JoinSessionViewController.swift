//
//  JoinSessionViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/21/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class JoinSessionViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.nameTextField.becomeFirstResponder()
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onJoinSession(_ sender: Any) {
        PlaylistClient.getPlaylist(name: nameTextField.text!) { (session, error) in
            if error != nil {
                print(error!)
            } else if session != nil {
                PlaylistSessionManager.sharedInstance.saveSession(session: session!, completion: { 
                    print("session successfully saved")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createPlaylistSessionSuccessful"), object: nil)
                })
            } else {
                print("no session found with that name")
                
                let alertController = UIAlertController(title: "Error", message: "No sessions found with that name", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
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
