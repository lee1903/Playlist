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
    static let apiURL = "http://localhost:8080/"
    
    private class func getDateString(currentDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy / HH:mm:ss"
        let date = dateFormatter.string(from: currentDate)
        return date
    }
    
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
        ref.child("sessions/\(session.name)/date").setValue(getDateString(currentDate: session.date))
        ref.child("sessions/\(session.name)/currentTrackIndex").setValue(session.currentTrackIndex)
    }
    
    //needs testing
    class func getPlaylist(name: String, completion:@escaping (PlaylistSession?, Error?) -> ()) {
        let url = apiURL + "sessions/name=\(name)"
        
        http.get(url, parameters: [], progress: { (progress) in }, success: { (dataTask: URLSessionDataTask, response: Any?) in
            
            let res = response! as! NSDictionary
            let session = PlaylistSession(dictionary: res)
            
            completion(session, nil)
            
        }) { (dataTask: URLSessionDataTask?, error: Error) in
            completion(nil, error)
        }
    }
    
    class func addTrackToPlaylist(session: PlaylistSession, track: Track) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/tracklist/\(track.name)").setValue(track.toDictionary())
    }
    
    class func upvoteTrack(session: PlaylistSession, track: Track) {
        let ref = FIRDatabase.database().reference()
        ref.child("sessions/\(session.name)/tracklist/\(track.name)/votes")
    }
    
    class func upvoteTrack(session: PlaylistSession, track: Track, completion:@escaping (String?, Error?) -> ()) {
        
        updateCurrentTrackIndex(session: session) { (res, error) in
            if error != nil {
                print(error!)
            } else {
                print(res!)
            }
        }
        
        let url = apiURL + "sessions/name=\(session.name)"
        
        let params = ["trackName" : track.name, "updateVote" : "1", "userName" : "\(SpotifyClient.sharedInstance.currentUser.name)", "userId" : "\(SpotifyClient.sharedInstance.currentUser.id)"]
        
        http.put(url, parameters: params, success: { (dataTask: URLSessionDataTask, response: Any?) in
            
            let resDictionary = response! as! NSDictionary
            let res = resDictionary["message"] as! String
            
            completion(res, nil)
            
        }) { (dataTask: URLSessionDataTask?, error: Error) in
            completion(nil, error)
        }
    }
    
    class func updateCurrentTrackIndex(session: PlaylistSession, completion:@escaping (String?, Error?) -> ()) {
        let url = apiURL + "sessions/name=\(session.name)"
        
        let params = ["updateCurrentTrackIndex" : "1", "currentTrackIndex" : "\(session.currentTrackIndex!)"]
        
        http.put(url, parameters: params, success: { (dataTask: URLSessionDataTask, response: Any?) in
            
            let resDictionary = response! as! NSDictionary
            let res = resDictionary["message"] as! String
            
            completion(res, nil)
            
        }) { (dataTask: URLSessionDataTask?, error: Error) in
            completion(nil, error)
        }
    }
}
