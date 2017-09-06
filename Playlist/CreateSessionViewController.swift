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
        if nameTextField.text != nil && !nameTextField.text!.contains("."){
            let playlistSession = PlaylistSession(name: nameTextField.text!)
            PlaylistClient.createPlaylistSession(session: playlistSession)
            PlaylistSessionManager.sharedInstance.saveSession(session: playlistSession, completion: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createPlaylistSessionSuccessful"), object: nil)
            })
        } else {
            print("error text field blank")
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
