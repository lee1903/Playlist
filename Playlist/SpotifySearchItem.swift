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
    var imageURL: String?
    
    init(type: String, item: Any) {
        self.type = type
        self.name = ""
        self.object = item
        self.imageURL = ""
        
        switch type {
        case "artist":
            let obj = item as! SPTPartialArtist
            self.name = obj.name!
        case "album":
            let obj = item as! SPTPartialAlbum
            self.name = obj.name!
        case "track":
            let obj = item as! SPTPartialTrack
            let artistObj = obj.artists[0] as! SPTPartialArtist
            self.name = obj.name! + " - " + artistObj.name
            self.imageURL = obj.album.smallestCover.imageURL.absoluteString
        default:
            print("error")
        }
    }
}
