//
//  User.swift
//  Playlist
//
//  Created by Brian Lee on 3/21/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.id, forKey: "id")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
    }
}
