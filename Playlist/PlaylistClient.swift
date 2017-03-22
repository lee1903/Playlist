//
//  PlaylistClient.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation
import AFNetworking

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
    
    class func createPlaylistSession(session: PlaylistSession, completion:@escaping (String?, Error?) -> ()) {
        let url = PlaylistClient.apiURL + "sessions/"
        let params = ["name" : "\(session.name)", "date": "\(getDateString(currentDate: session.date))"]
        print(params)
        
        http.post(url, parameters: params, progress: { (progress: Progress) -> Void in
        }, success: { (dataTask: URLSessionDataTask, response: Any?) -> Void in
            
            let resDictionary = response! as! NSDictionary
            let res = resDictionary["message"] as! String
            
            completion(res, nil)
            
            
        }) { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            
            completion(nil, error)
        }
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
    
    class func addTrackToPlaylist(session: PlaylistSession, track: Track, completion:@escaping (String?, Error?) -> ()) {
        let url = apiURL + "sessions/name=\(session.name)"
        
        let params = ["name" : "\(track.name)", "playableURI" : "\(track.playableURI)", "votes" : "\(track.votes)", "artist" : "\(track.artist)", "title" : "\(track.title)", "userName" : "\(SpotifyClient.sharedInstance.currentUser.name)", "userId" : "\(SpotifyClient.sharedInstance.currentUser.id)"]
        
        http.put(url, parameters: params, success: { (dataTask: URLSessionDataTask, response: Any?) in
            
            let resDictionary = response! as! NSDictionary
            let res = resDictionary["message"] as! String
            
            completion(res, nil)
            
        }) { (dataTask: URLSessionDataTask?, error: Error) in
            completion(nil, error)
        }
        
    }
    
    class func getTracklist(session: PlaylistSession, completion:@escaping ([Track]?, Error?) -> ()) {
        let url = apiURL + "sessions/tracklist/name=\(session.name)"
        
        http.get(url, parameters: [], progress: { (progress) in }, success: { (dataTask: URLSessionDataTask, response: Any?) in
            
            let resArray = response! as! NSArray
            let tracklist = getTracklistFromJSON(jsonArray: resArray)
            
            completion(tracklist, nil)
            
        }) { (dataTask: URLSessionDataTask?, error: Error) in
            completion(nil, error)
        }
        
    }
    
    class func upvoteTrack(session: PlaylistSession, track: Track, completion:@escaping (String?, Error?) -> ()) {
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
}
