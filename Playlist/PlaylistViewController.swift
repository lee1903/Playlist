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
    @IBOutlet weak var mediaControlsView: UIView!
    
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
        setCurrentTrackIndexListener()
        
        if PlaylistSessionManager.sharedInstance.session?.admin != SpotifyClient.sharedInstance.currentUser.id {
            mediaControlsView.isHidden = true
        }
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
            PlaylistSessionManager.sharedInstance.session?.sortTracklist()
            
            self.tableData = PlaylistSessionManager.sharedInstance.session?.tracklist
            self.tableView.reloadData()
            
//            if (self.tableData?.count)! > 0 {
//                if PlaylistSessionManager.sharedInstance.session!.currentTrackIndex >= 0{
//                    let indexPath = IndexPath(row: PlaylistSessionManager.sharedInstance.session!.currentTrackIndex, section: 0)
//                    self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
//                }
//            }
            
        })
    }
    
    func setCurrentTrackIndexListener() {
        let currentTrackIndexRef = FIRDatabase.database().reference(withPath: "sessions/\(PlaylistSessionManager.sharedInstance.session!.name)/currentTrackIndex")
        
        currentTrackIndexRef.observe(.value, with: { snapshot in
            
            if let index = snapshot.value as? Int {
                PlaylistSessionManager.sharedInstance.session?.currentTrackIndex = index
            }
            
            self.tableView.reloadData()
            
            if self.tableData != nil {
                if (self.tableData?.count)! > 0 {
                    if (PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)! >= 0{
                        let indexPath = IndexPath(row: (PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)!, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                    }
                }
            }
            
        })

    }
    
    func playNextSong() {
        let currentIndex = PlaylistSessionManager.sharedInstance.session!.currentTrackIndex
        if currentIndex >= 0 {
            //checks if current song is the last song in queue
            if currentIndex + 1 < (PlaylistSessionManager.sharedInstance.session?.tracklist.count)! {
                self.currentTrackOffset = nil
                PlaylistSessionManager.sharedInstance.session?.currentTrackIndex = currentIndex + 1
                let currentTrack = PlaylistSessionManager.sharedInstance.session!.tracklist[currentIndex + 1]
                self.playSong(spotifyURI: currentTrack.playableURI.absoluteString)
                self.tableView.reloadData()
                
                PlaylistClient.updateCurrentTrackIndex(session: PlaylistSessionManager.sharedInstance.session!)
                PlaylistClient.setTrackTimePlayed(session: PlaylistSessionManager.sharedInstance.session!, track: currentTrack)
            }
        }
    }

    @IBAction func onEndSession(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "PlaylistSession")
        userDefaults.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userEndedSession"), object: nil)
    }
    
    
    @IBAction func onPlay(_ sender: Any) {
        if notPlaying == true {
            //checks to make sure queue is not empty
            if (PlaylistSessionManager.sharedInstance.session?.tracklist.count)! > 0 {
                //if no song has been played yet, set currentTrackIndex to 0
                if PlaylistSessionManager.sharedInstance.session?.currentTrackIndex == -1 {
                    PlaylistSessionManager.sharedInstance.session?.currentTrackIndex = 0
                    PlaylistClient.updateCurrentTrackIndex(session: PlaylistSessionManager.sharedInstance.session!)
                }
                let currentTrack = PlaylistSessionManager.sharedInstance.session!.tracklist[(PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)!]
                
                //updates timePlayed in Firebase
                PlaylistClient.setTrackTimePlayed(session: PlaylistSessionManager.sharedInstance.session!, track: currentTrack)
                
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
        playNextSong()
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
            if indexPath.row == currentIndex {
                //current song playing
                cell.voteButton.isHidden = true
                cell.voteLabel.isHidden = true
                cell.nowPlayingImage.isHidden = false
                cell.nameLabel.textColor = UIColor.red
                cell.artistLabel.textColor = UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0)
                cell.albumCover.alpha = 1
            } else if indexPath.row < currentIndex {
                //song has already been played
                cell.voteButton.isHidden = true
                cell.voteLabel.isHidden = true
                cell.nowPlayingImage.isHidden = true
                cell.nameLabel.textColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
                cell.artistLabel.textColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
                cell.albumCover.alpha = 0.3
            } else {
                //song has yet to play
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

extension PlaylistViewController: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
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
            player?.playbackDelegate = self
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
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        if event == SPPlaybackNotifyTrackDelivered {
            playNextSong()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        let currentTrack = tableData?[(PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)!]
        let progress = Double(position)/(currentTrack?.duration)!
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
