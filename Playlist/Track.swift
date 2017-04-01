//
//  Track.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation
import Firebase

class Track: NSObject {
    let name: String
    let artist: String
    let title: String
    let playableURI: URL
    //var votes: [User]
    var votes: [User]
    var didVote: Bool
    let imageURL: String
    
    init(track: SPTPartialTrack) {
        self.playableURI = track.playableUri
        self.votes = [SpotifyClient.sharedInstance.currentUser]
        self.title = track.name
        
        let artistObj = track.artists[0] as! SPTPartialArtist
        self.artist = artistObj.name
        
        self.name = self.title + " - " + self.artist
        self.didVote = true
        self.imageURL = track.album.smallestCover.imageURL.absoluteString
    }
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as! String
        self.artist = dictionary["artist"] as! String
        self.title = dictionary["title"] as! String
        self.votes = []
        self.playableURI = URL(string: dictionary["playableURI"] as! String)!
        
        let votesDictionary = dictionary["votes"] as! [String : String]
        for obj in votesDictionary {
            let user = User(key: obj.key, value: obj.value)
            self.votes.append(user)
        }
        
        print(SpotifyClient.sharedInstance.currentUser.id)
        
        self.didVote = false
        for user in self.votes {
            if user.id == SpotifyClient.sharedInstance.currentUser.id {
                self.didVote = true
                break
            }
        }
        
        self.imageURL = dictionary["imageURL"] as! String
        
    }
    
    func toDictionary() -> [String : Any] {
        var voteDictionary: [String : String] = [:]
        for user in self.votes {
            voteDictionary[user.id] = user.name
        }
        let dic = ["name" : "\(self.name)", "playableURI" : "\(self.playableURI)", "votes" : voteDictionary, "artist" : "\(self.artist)", "title" : "\(self.title)", "imageURL" : "\(self.imageURL)"] as [String : Any]
        
        return dic
    }
}
