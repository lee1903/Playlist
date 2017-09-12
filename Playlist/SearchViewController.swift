//
//  SearchViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/13/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var tableData: [Track]?
    var session: SPTSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        let userDefaults = UserDefaults.standard
        let sessionObj:Any = userDefaults.object(forKey: "SpotifySession")
        let sessionDataObj = sessionObj as! Data
        self.session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false 
        view.addGestureRecognizer(tap)
        
        self.searchBar.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func searchSpotify(query: String) {
        SPTSearch.perform(withQuery: query, queryType: SPTSearchQueryType.queryTypeTrack, accessToken: session.accessToken) { (error, response) in
            if error != nil {
                print(error!)
            } else {
                let listpage = response as! SPTListPage
                self.updateTableData(response: listpage, type: SPTSearchQueryType.queryTypeTrack)
            }
        }
    }
    
    func queueSongPressed(sender: UIButton) {
        let track = tableData![sender.tag]
        
        print(track.name + " has been added to queue")
        
        PlaylistClient.addTrackToPlaylist(session: PlaylistSessionManager.sharedInstance.session!, track: track)
        sender.setImage(UIImage(named: "Check"), for: .normal)
        sender.isUserInteractionEnabled = false
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func updateTableData(response: SPTListPage, type: SPTSearchQueryType) {
        var items = [Track]()
        
        if response.items != nil{
            for obj in response.items {
                let spotifyItem = Track(track: obj as! SPTPartialTrack)
                items.append(spotifyItem)
            }
            
            self.tableData = items
            tableView.reloadData()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData != nil {
            return tableData!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchDataCell", for: indexPath) as! SearchDataCell
        
        let track = tableData![indexPath.row]
        
        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        cell.albumCoverImageView.setImageWith(URL(string: track.imageURL)!)
        cell.queueSongButton.tag = indexPath.row
        cell.queueSongButton.addTarget(self, action: #selector(queueSongPressed), for: .touchUpInside)
        
        cell.selectionStyle = .none
        
        if(PlaylistSessionManager.sharedInstance.session!.history[track.playableURI.absoluteString] != nil) {
            cell.queueSongButton.setImage(UIImage(named: "Check"), for: .normal)
            cell.queueSongButton.isUserInteractionEnabled = false
        } else {
            cell.queueSongButton.setImage(UIImage(named: "Plus"), for: .normal)
            cell.queueSongButton.isUserInteractionEnabled = true
        }
        
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search button clicked")
        
        let query = searchBar.text
        
        searchSpotify(query: query!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchBar.text
        
        searchSpotify(query: query!)
    }
}
