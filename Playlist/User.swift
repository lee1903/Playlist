//
//  User.swift
//  Playlist
//
//  Created by Brian Lee on 3/21/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class User: NSObject {
    let name: String
    let id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
}
