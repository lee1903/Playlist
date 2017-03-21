//
//  Track.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class Track: NSObject {
    let name: String
    let artist: String
    let title: String
    let playableURI: URL
    let votes: Int
    
    init(track: SPTPartialTrack) {
        self.playableURI = track.playableUri
        self.votes = 1
        self.title = track.name
        
        let artistObj = track.artists[0] as! SPTPartialArtist
        self.artist = artistObj.name
        
        self.name = self.title + " - " + self.artist
    }
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as! String
        self.artist = dictionary["artist"] as! String
        self.title = dictionary["title"] as! String
        self.playableURI = URL(string: dictionary["playableURI"] as! String)!
        self.votes = dictionary["votes"] as! Int
    }
}
