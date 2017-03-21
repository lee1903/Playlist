//
//  PlaylistSession.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import Foundation

class PlaylistSession: NSObject, NSCoding {
    let name: String
    let date: Date
    let tracklist: [Track]
    
    init(name: String) {
        self.name = name
        self.date = Date()
        self.tracklist = []
    }
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy / HH:mm:ss"
        let date = dateFormatter.date(from: dictionary["date"] as! String)
        self.date = date!
        
        //let tracklistArray = dictionary["tracklist"] as! NSArray
        
        //create track objects from tracklistArray
        self.tracklist = []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.date, forKey: "date")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        self.tracklist = []
    }
}

