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
    let playableURI: URL
    let votes: Int
    
    init(track: SPTPartialTrack) {
        self.name = track.name
        self.playableURI = track.playableUri
        self.votes = 1
    }
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as! String
        self.playableURI = URL(string: dictionary["playableURI"] as! String)!
        self.votes = dictionary["votes"] as! Int
    }
}
