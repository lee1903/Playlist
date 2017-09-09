//
//  PlaylistClient.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation
import AFNetworking
import Firebase

class PlaylistClient {
    
    static let http = AFHTTPSessionManager()

    
    private class func getTracklistFromJSON(jsonArray: NSArray) -> [Track] {
        var tracklist: [Track] = []
        for obj in jsonArray {
            let track = Track(dictionary: obj as! NSDictionary)
            tracklist.append(track)
        }
        
        return tracklist
    }
    
    class func createPlaylistSession(session: PlaylistSession) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)").setValue(session.toDictionary())
    }
    
    class func playlistAlreadyExists(sessionName: String, completion:@escaping (Bool) -> ()) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions").child(sessionName).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    class func getPlaylist(name: String, completion:@escaping (PlaylistSession?, Error?) -> ()) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                print(value)
                let session = PlaylistSession(dictionary: value)
                
                completion(session, nil)
            } else {
                completion(nil, nil)
            }
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    class func getCurrentTrack(session: PlaylistSession, completion:@escaping (Int?, Error?) -> ()) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(PlaylistSessionManager.sharedInstance.session!.name)/currentTrackIndex").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get current track value one time
            if let value = snapshot.value as? Int {                
                completion(value, nil)
            } else {
                completion(nil, nil)
            }
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }

    
    class func addTrackToPlaylist(session: PlaylistSession, track: Track) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/tracklist/\(track.playableURI)").setValue(track.toDictionary())
    }
    
    class func upvoteTrack(session: PlaylistSession, track: Track) {
        let date = NSDate()
        let currentTime = UInt64(date.timeIntervalSince1970 * 1000.0)
        
        let ref = FIRDatabase.database().reference()
        let trackRef = ref.child("sessions/\(session.name)/tracklist/\(track.playableURI)")
        
        let newData: [String : Any] = ["votes/\(SpotifyClient.sharedInstance.currentUser.id)" : SpotifyClient.sharedInstance.currentUser.name, "timeUpvoted" : currentTime]
        
        trackRef.updateChildValues(newData)
        
        
//        ref.child("sessions/\(session.name)/tracklist/\(track.playableURI)/votes/\(SpotifyClient.sharedInstance.currentUser.id)").setValue(SpotifyClient.sharedInstance.currentUser.name)
//        ref.child("sessions/\(session.name)/tracklist/\(track.playableURI)/timeUpvoted").setValue(currentTime)
    }
    
    class func updateCurrentTrackIndex(session: PlaylistSession) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/currentTrackIndex").setValue(session.currentTrackIndex)
    }
    
    class func setTrackTimePlayed(session: PlaylistSession, track: Track) {
        let date = NSDate()
        let currentTime = UInt64(date.timeIntervalSince1970 * 1000.0)
        
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/tracklist/\(track.playableURI)/timePlayed").setValue(currentTime)
    }
    
    class func endPlaylistSession(session: PlaylistSession) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)").removeValue()
    }
}
