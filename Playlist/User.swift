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
        //self.id = id
        self.id = "alifjbb8abc3yr98h23h"
    }
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as! String
        self.id = dictionary["id"] as! String
    }
}
