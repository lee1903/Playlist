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
    var history: [String: Bool]
    let admin: String
    var currentTrackIndex: Int
    
    init(name: String) {
        self.name = name
        self.date = Date()
        self.tracklist = []
        self.history = [:]
        self.admin = SpotifyClient.sharedInstance.currentUser.id
        self.currentTrackIndex = -1
    }
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy / HH:mm:ss"
        let date = dateFormatter.date(from: dictionary["date"] as! String)
        self.date = date!
        
        self.history = [:]
        self.tracklist = []
        self.admin = dictionary["admin"] as! String
        self.currentTrackIndex = dictionary["currentTrackIndex"] as! Int
    }
    
    func sortTracklist() {
        if tracklist.count > 0 {
            self.tracklist.sort(by: { (trackA, trackB) -> Bool in
                if trackA.timePlayed == 0 && trackB.timePlayed == 0 {
                    //neither song has been played yet, sort by time queued in chronological order
                    return trackA.timeQueued < trackB.timeQueued
                } else if trackA.timePlayed == 0 && trackB.timePlayed != 0 {
                    //trackA hasn't been played but trackB has, trackB goes first
                    return false
                } else if trackA.timePlayed != 0 && trackB.timePlayed == 0 {
                    //trackB hasn't been played but trackA has, trackA goes first
                    return true
                } else {
                    //trackA and trackB have both been played, sort by time played in chronological order
                    return trackA.timePlayed < trackB.timePlayed
                }
            })
            var unplayedTracklist = Array(self.tracklist[self.currentTrackIndex+1..<self.tracklist.count])
            unplayedTracklist.sort(by: { (trackA, trackB) -> Bool in
                //sorts uplayed portion of tracklist by vote count in descending order
                //if vote count is the same, sort by time upvoted in chronological order
                if trackA.votes.count == trackB.votes.count {
                    return trackA.timeUpvoted < trackB.timeUpvoted
                } else {
                    return trackA.votes.count > trackB.votes.count
                }
            })
            let sortedTracklist = Array(self.tracklist[0..<self.currentTrackIndex+1]) + unplayedTracklist
            self.tracklist = sortedTracklist
        }
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
        self.history = [:]
        self.currentTrackIndex = aDecoder.decodeObject(forKey: "currentTrackIndex") as? Int ?? -1
    }
    
    private func getDateString(currentDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy / HH:mm:ss"
        let date = dateFormatter.string(from: currentDate)
        return date
    }
}

