//
//  PlaylistViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var tableData: [Track]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navBar.topItem?.title = PlaylistSessionManager.sharedInstance.session?.name
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistViewController.updateTracklist), name: NSNotification.Name(rawValue: "updateTracklist"), object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTracklist() {
        PlaylistClient.getTracklist(session: PlaylistSessionManager.sharedInstance.session!) { (tracklist, error) in
            if error != nil {
                print(error)
            } else {
                PlaylistSessionManager.sharedInstance.session?.tracklist = tracklist!
                self.tableData = tracklist
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func onEndSession(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "PlaylistSession")
        userDefaults.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userEndedSession"), object: nil)
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        updateTracklist()
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

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData != nil {
            return tableData!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        
        cell.nameLabel.text = tableData![indexPath.row].name
        cell.voteLabel.text = "\(tableData![indexPath.row].votes.count)"
        cell.track = tableData![indexPath.row]
        if tableData![indexPath.row].didVote {
            cell.voteButton.setImage(UIImage(named: "Circle-Up-Filled"), for: UIControlState.normal)
        }
        if indexPath.row == 0 {
            cell.voteButton.isHidden = true
            cell.voteLabel.isHidden = true
        } else {
            cell.nowPlayingImage.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
