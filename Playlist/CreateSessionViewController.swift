//
//  CreatePlaylistSessionViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class CreateSessionViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.keyboardAppearance = .light
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Session Name", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.nameTextField.becomeFirstResponder()
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: Any) {
        
        guard !(nameTextField.text?.isEmpty)! else {
            displayAlert(message: "You must enter a name for the session")
            return
        }
        
        //Todo - no special characters
        guard !nameTextField.text!.contains(".") else {
            displayAlert(message: "You can not have a period in the session name")
            return
        }
        
        //check if Playlist with same name already exists
        PlaylistClient.playlistAlreadyExists(sessionName: nameTextField.text!) { (exists) in
            if exists {
                self.displayAlert(message: "A session with this name already exists")
            } else {
                let playlistSession = PlaylistSession(name: self.nameTextField.text!)
                PlaylistClient.createPlaylistSession(session: playlistSession)
                PlaylistSessionManager.sharedInstance.saveSession(session: playlistSession, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createPlaylistSessionSuccessful"), object: nil)
                })
            }
        }
        
        
    }
    
    func displayAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
