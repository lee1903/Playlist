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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onEndSession(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "PlaylistSession")
        userDefaults.synchronize()
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        PlaylistClient.getTracklist(session: PlaylistSessionManager.sharedInstance.session!) { (tracklist, error) in
            if error != nil {
                print(error)
            } else {
                self.tableData = tracklist
                self.tableView.reloadData()
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
        cell.voteLabel.text = "\(tableData![indexPath.row].votes)"
        
        return cell
    }
}