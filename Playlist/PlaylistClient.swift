//
//  PlaylistClient.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class PlaylistClient: NSObject {
    
    var session: PlaylistSession?
    
    class var sharedInstance: PlaylistClient {
        struct Static {
            static let instance = PlaylistClient()
        }
        return Static.instance
    }
}
