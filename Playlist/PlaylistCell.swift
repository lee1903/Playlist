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
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var voteButton: UIButton!
    
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var albumCover: UIImageView!
    
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
            PlaylistClient.upvoteTrack(session: PlaylistSessionManager.sharedInstance.session!, track: track!)
        }
    }
}
