//
//  PlaylistViewController.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit
import Firebase

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var playButton: UIButton!
    
    var tableData: [Track]?
    
    var player: SPTAudioStreamingController?
    let clientID = "b9e60d3ffe6e4df8bbab4267ee07470f"
    
    let userDefaults = UserDefaults.standard
    
    var notPlaying: Bool!
    var currentTrackOffset: TimeInterval?
    
    var ref: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        notPlaying = true
        
        navBar.topItem?.title = PlaylistSessionManager.sharedInstance.session?.name
        
        self.setUpAudioStreamer(sessionObj: SpotifyClient.sharedInstance.session)
        
        setTracklistListener()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistViewController.setTracklistListener), name: NSNotification.Name(rawValue: "updateTracklist"), object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTracklistListener() {
        let tracklistRef = FIRDatabase.database().reference(withPath: "sessions/\(PlaylistSessionManager.sharedInstance.session!.name)/tracklist")
        
        tracklistRef.observe(.value, with: { snapshot in
            var newItems: [Track] = []
            
            let trackArray = snapshot.value as? [String : AnyObject] ?? [:]
            for item in trackArray {
                let trackDict = item.value as! NSDictionary
                let track = Track(dictionary: trackDict)
                newItems.append(track)
            }
            
            PlaylistSessionManager.sharedInstance.session?.tracklist = newItems
            
            self.tableData = newItems
            self.tableView.reloadData()
            
            if let currentIndex = PlaylistSessionManager.sharedInstance.session?.currentTrackIndex {
                let indexPath = IndexPath(row: currentIndex, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            }
        })
    }

    @IBAction func onEndSession(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "PlaylistSession")
        userDefaults.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userEndedSession"), object: nil)
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        setTracklistListener()
    }
    
    
    @IBAction func onPlay(_ sender: Any) {
        if notPlaying == true {
            if (PlaylistSessionManager.sharedInstance.session?.tracklist.count)! > 0 {
                let currentTrack = PlaylistSessionManager.sharedInstance.session!.tracklist[(PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)!]
                self.playSong(spotifyURI: currentTrack.playableURI.absoluteString)
                self.playButton.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
                self.notPlaying = false
                self.tableView.reloadData()
            }
        } else {
            self.currentTrackOffset = player?.playbackState.position
            player?.setIsPlaying(false, callback: { (error) in
                if error != nil {
                    print("error pausing")
                } else {
                    self.playButton.setImage(UIImage(named: "Play"), for: UIControlState.normal)
                    self.notPlaying = true
                }
            })
        }

    }
    
    @IBAction func onNext(_ sender: Any) {
        if let currentIndex = PlaylistSessionManager.sharedInstance.session?.currentTrackIndex {
            if currentIndex + 1 < (PlaylistSessionManager.sharedInstance.session?.tracklist.count)! {
                self.currentTrackOffset = nil
                PlaylistSessionManager.sharedInstance.session?.currentTrackIndex = currentIndex + 1
                let currentTrack = PlaylistSessionManager.sharedInstance.session!.tracklist[currentIndex + 1]
                self.playSong(spotifyURI: currentTrack.playableURI.absoluteString)
                self.tableView.reloadData()
                
                PlaylistClient.updateCurrentTrackIndex(session: PlaylistSessionManager.sharedInstance.session!)
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
        
        cell.nameLabel.text = tableData![indexPath.row].title
        cell.artistLabel.text = tableData![indexPath.row].artist
        cell.voteLabel.text = "\(tableData![indexPath.row].votes.count)"
        cell.track = tableData![indexPath.row]
        
        let url = URL(string: tableData![indexPath.row].imageURL)
        cell.albumCover.setImageWith(url!)
        
        if tableData![indexPath.row].didVote {
            cell.voteButton.setImage(UIImage(named: "Circle-Up-Filled"), for: UIControlState.normal)
        } else {
            cell.voteButton.setImage(UIImage(named: "Circle-Up"), for: UIControlState.normal)
        }
        
        if let currentIndex = PlaylistSessionManager.sharedInstance.session?.currentTrackIndex {
            if indexPath.row == currentIndex && !notPlaying {
                cell.voteButton.isHidden = true
                cell.voteLabel.isHidden = true
                cell.nowPlayingImage.isHidden = false
                cell.nameLabel.textColor = UIColor.red
                cell.artistLabel.textColor = UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0)
                cell.albumCover.alpha = 1
            } else if indexPath.row < currentIndex {
                cell.voteButton.isHidden = true
                cell.voteLabel.isHidden = true
                cell.nowPlayingImage.isHidden = true
                cell.nameLabel.textColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
                cell.artistLabel.textColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
                cell.albumCover.alpha = 0.3
            } else {
                cell.voteButton.isHidden = false
                cell.voteLabel.isHidden = false
                cell.nowPlayingImage.isHidden = true
                cell.nameLabel.textColor = UIColor.black
                cell.artistLabel.textColor = UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0)
                cell.albumCover.alpha = 1
            }
        } else {
            cell.nowPlayingImage.isHidden = true
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension PlaylistViewController: SPTAudioStreamingDelegate {
    
    func setUpAudioStreamer(sessionObj: SPTSession!) {
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
        if currentTrackOffset != nil {
            player?.playSpotifyURI(spotifyURI, startingWith: 0, startingWithPosition: currentTrackOffset!, callback: { (error) in
                if error != nil {
                    print("error playing uri")
                    print(error!)
                }
            })
        } else {
            player?.playSpotifyURI(spotifyURI, startingWith: 0, startingWithPosition: 0, callback: { (error) in
                if error != nil {
                    print("error playing uri")
                    print(error!)
                }
            })
        }
    }
}
