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
//        self.name = "Aidan Lowe"
//        self.id = "alifjba377c321fv8h23h"
    }
    
    init(key: String, value: String) {
        self.name = value
        self.id = key
    }
}
