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
    @IBOutlet weak var queryTypeSegmentedControl: UISegmentedControl!
    
    var tableData: [SpotifySearchItem]?
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchSpotify(query: String) {
        
        let type: SPTSearchQueryType?
        
        switch queryTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            type = SPTSearchQueryType.queryTypeTrack
        case 1:
            type = SPTSearchQueryType.queryTypeArtist
        case 2:
            type = SPTSearchQueryType.queryTypeAlbum
        default:
            type = nil
        }
        
        SPTSearch.perform(withQuery: query, queryType: type!, accessToken: session.accessToken) { (error, response) in
            if error != nil {
                print(error)
            }
            let listpage = response as! SPTListPage
            self.updateTableData(response: listpage, type: type!)
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func updateTableData(response: SPTListPage, type: SPTSearchQueryType) {
        
        var typeString = ""
        var items = [SpotifySearchItem]()
        
        switch type {
        case SPTSearchQueryType.queryTypeTrack:
            typeString = "track"
        case SPTSearchQueryType.queryTypeArtist:
            typeString = "artist"
        case SPTSearchQueryType.queryTypeAlbum:
            typeString = "album"
        default:
            print("error")
        }
        
        
        if response.items != nil{
            for obj in response.items {
                let spotifyItem = SpotifySearchItem(type: typeString, item: obj)
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
        
        cell.nameLabel.text = tableData?[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if queryTypeSegmentedControl.selectedSegmentIndex == 0 {
            let trackObj = tableData?[indexPath.row].object as! SPTPartialTrack
            let track = Track(track: trackObj)
            PlaylistClient.addTrackToPlaylist(session: PlaylistSessionManager.sharedInstance.session!, track: track, completion: { (response, error) in
                if error != nil {
                    print(error)
                } else {
                    print(response)
                }
            })
        }
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
