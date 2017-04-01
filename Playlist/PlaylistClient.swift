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

    
    class func addTrackToPlaylist(session: PlaylistSession, track: Track) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/tracklist/\(track.playableURI)").setValue(track.toDictionary())
    }
    
    class func upvoteTrack(session: PlaylistSession, track: Track) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/tracklist/\(track.playableURI)/votes/\(SpotifyClient.sharedInstance.currentUser.id)").setValue(SpotifyClient.sharedInstance.currentUser.name)
    }
    
    class func updateCurrentTrackIndex(session: PlaylistSession) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/currentTrackIndex").setValue(session.currentTrackIndex)
    }
}
