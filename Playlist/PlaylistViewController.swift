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
    @IBOutlet weak var endSessionButton: UIBarButtonItem!
    
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
        
        if isAdmin() {
            self.setUpAudioStreamer(sessionObj: SpotifyClient.sharedInstance.session)
        } else {
            mediaControlsView.isHidden = true
            endSessionButton.title = "Leave"
        }
        
        notPlaying = true
        
        navBar.topItem?.title = PlaylistSessionManager.sharedInstance.session?.name
        
        setTracklistListener()
        setCurrentTrackIndexListener()
        setSessionEndListener()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSessionEndListener() {
        let tracklistRef = FIRDatabase.database().reference(withPath: "sessions/\(PlaylistSessionManager.sharedInstance.session!.name)/")
        
        //if session has been ended, log out audio streaming
        tracklistRef.observe(.value, with: { snapshot in
            if !snapshot.exists() {
                print("session ended")
                self.player?.logout()
                
                let alertController = UIAlertController(title: "Sorry", message: "Party's over. The host has ended the session :(", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.leavePlaylistSession()
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func setTracklistListener() {
        let tracklistRef = FIRDatabase.database().reference(withPath: "sessions/\(PlaylistSessionManager.sharedInstance.session!.name)/tracklist")
        
        tracklistRef.observe(.value, with: { snapshot in
            var newItems: [Track] = []
            
            //get the new tracklist if its been changed
            let trackArray = snapshot.value as? [String : AnyObject] ?? [:]
            for item in trackArray {
                //add track to tracklist
                let trackDict = item.value as! NSDictionary
                let track = Track(dictionary: trackDict)
                newItems.append(track)
                //add track to history
                PlaylistSessionManager.sharedInstance.session!.history[track.playableURI.absoluteString] = true
            }
            
            //update session with new tracklist and sort tracks
            PlaylistSessionManager.sharedInstance.session?.tracklist = newItems
            PlaylistSessionManager.sharedInstance.session?.sortTracklist()
            
            //update table view with new tracklist
            self.tableData = PlaylistSessionManager.sharedInstance.session?.tracklist
            self.tableView.reloadData()
            
            print(PlaylistSessionManager.sharedInstance.session!.history)
        })
    }
    
    func setCurrentTrackIndexListener() {
        let currentTrackIndexRef = FIRDatabase.database().reference(withPath: "sessions/\(PlaylistSessionManager.sharedInstance.session!.name)/currentTrackIndex")
        
        currentTrackIndexRef.observe(.value, with: { snapshot in
            
            //update session when current track has been changed
            if let index = snapshot.value as? Int {
                PlaylistSessionManager.sharedInstance.session?.currentTrackIndex = index
            }
            
            self.tableView.reloadData()
            
            guard self.tableData != nil else { return }
            guard (self.tableData?.count)! > 0 else { return }
            
            //if table is initialized and not empty, scroll table view to the current track
            if (PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)! >= 0{
                let indexPath = IndexPath(row: (PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)!, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            }
        })

    }
    
    func playNextSong() {
        let currentIndex = PlaylistSessionManager.sharedInstance.session!.currentTrackIndex
        
        //check if music has started playing yet
        guard currentIndex >= 0 else { return }
        //check if end of queue has been reached
        guard currentIndex + 1 < (PlaylistSessionManager.sharedInstance.session?.tracklist.count)! else { return }
        
        //reset the current track offset
        self.currentTrackOffset = nil
        
        //increment the index and play the next song
        PlaylistSessionManager.sharedInstance.session?.currentTrackIndex = currentIndex + 1
        let currentTrack = PlaylistSessionManager.sharedInstance.session!.tracklist[currentIndex + 1]
        self.playSong(spotifyURI: currentTrack.playableURI.absoluteString)
        self.tableView.reloadData()
        
        //update the db with new current track
        PlaylistClient.updateCurrentTrackIndex(session: PlaylistSessionManager.sharedInstance.session!)
        PlaylistClient.setTrackTimePlayed(session: PlaylistSessionManager.sharedInstance.session!, track: currentTrack)
    }
    
    func playCurrentSong() {
        //checks to make sure queue is not empty
        guard (PlaylistSessionManager.sharedInstance.session?.tracklist.count)! > 0 else { return }
        
        //if no song has been played yet, set current track to first song
        if PlaylistSessionManager.sharedInstance.session?.currentTrackIndex == -1 {
            PlaylistSessionManager.sharedInstance.session?.currentTrackIndex = 0
            PlaylistClient.updateCurrentTrackIndex(session: PlaylistSessionManager.sharedInstance.session!)
        }
        
        let currentTrack = PlaylistSessionManager.sharedInstance.session!.tracklist[(PlaylistSessionManager.sharedInstance.session?.currentTrackIndex)!]
        
        //update time song played in db
        PlaylistClient.setTrackTimePlayed(session: PlaylistSessionManager.sharedInstance.session!, track: currentTrack)
        
        self.playSong(spotifyURI: currentTrack.playableURI.absoluteString)

        self.tableView.reloadData()
    }
    
    func pauseCurrentSong() {
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
    
    func isAdmin() -> Bool {
        return PlaylistSessionManager.sharedInstance.session?.admin == SpotifyClient.sharedInstance.currentUser.id
    }
    
    func leavePlaylistSession() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "PlaylistSession")
        userDefaults.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userEndedSession"), object: nil)
    }

    @IBAction func onEndSession(_ sender: Any) {
        leavePlaylistSession()
        
        //if admin ends the session, remove session from db
        if isAdmin() {
            PlaylistClient.endPlaylistSession(session: PlaylistSessionManager.sharedInstance.session!)
        }
    }
    
    
    @IBAction func onPlay(_ sender: Any) {
        if notPlaying == true {
            //music is not playing, start playing music
            playCurrentSong()
        } else {
            //music is currently playing, pause music
            pauseCurrentSong()
        }

    }
    
    @IBAction func onNext(_ sender: Any) {
        playNextSong()
    }
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
        
        let track = tableData![indexPath.row]
        
        cell.nameLabel.text = track.title
        cell.artistLabel.text = track.artist
        cell.voteLabel.text = "\(track.votes.count)"
        cell.track = track
        cell.albumCover.setImageWith(URL(string: track.imageURL)!)
        
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
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("audo stream logged out")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        if event == SPPlaybackNotifyTrackDelivered {
            playNextSong()
        }
    }
    
    
    func playSong(spotifyURI: String) {
        //if music is not currently playing, change the play/pause button to pause
        if notPlaying == true {
            self.playButton.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
            self.notPlaying = false
        }
        
        //if song was previously paused, play from where it was paused, otherwise play from start
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
