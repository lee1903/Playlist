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
    var tracklist: [Track]
    let admin: String
    var currentTrackIndex: Int
    
    init(name: String) {
        self.name = name
        self.date = Date()
        self.tracklist = []
        self.admin = SpotifyClient.sharedInstance.currentUser.id
        self.currentTrackIndex = -1
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
        self.admin = dictionary["admin"] as! String
        self.currentTrackIndex = dictionary["currentTrackIndex"] as! Int
    }
    
    func toDictionary() -> [String : Any] {
        let dic = ["name" : "\(self.name)", "admin" : "\(self.admin)", "date" : "\(getDateString(currentDate: self.date))", "currentTrackIndex" : self.currentTrackIndex] as [String : Any]
        
        return dic
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.admin, forKey: "admin")
        aCoder.encode(self.currentTrackIndex, forKey: "currentTrackIndex")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        self.admin = aDecoder.decodeObject(forKey: "admin") as? String ?? ""
        self.tracklist = []
        self.currentTrackIndex = aDecoder.decodeObject(forKey: "currentTrackIndex") as? Int ?? -1
    }
    
    private func getDateString(currentDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy / HH:mm:ss"
        let date = dateFormatter.string(from: currentDate)
        return date
    }
}

