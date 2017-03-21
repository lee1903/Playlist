//
//  SpotifySearchItem.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class SpotifySearchItem: NSObject {
    var name: String?
    let type: String?
    let object: Any?
    
    init(type: String, item: Any) {
        self.type = type
        self.name = ""
        self.object = item
        
        switch type {
        case "artist":
            let obj = item as! SPTPartialArtist
            self.name = obj.name!
        case "album":
            let obj = item as! SPTPartialAlbum
            self.name = obj.name!
        case "track":
            let obj = item as! SPTPartialTrack
            self.name = obj.name!
        default:
            print("error")
        }
    }
}
