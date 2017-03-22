//
//  PlaylistCell.swift
//  Playlist
//
//  Created by Brian Lee on 3/19/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    
    @IBOutlet weak var voteButton: UIButton!
    
    var track: Track?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onUpvote(_ sender: Any) {
        if !(track?.didVote)! {
            PlaylistClient.upvoteTrack(session: PlaylistSessionManager.sharedInstance.session!, track: track!) { (response, error) in
                if error != nil{
                    print(error)
                } else{
                    print(response)
                    //self.voteButton.setImage(UIImage(named: "Circle-Up-Filled"), for: UIControlState.normal)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTracklist"), object: nil)
                }
            }
        }
    }
}
