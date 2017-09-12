//
//  SearchDataCell.swift
//  Playlist
//
//  Created by Brian Lee on 3/13/17.
//  Copyright © 2017 brianlee. All rights reserved.
//

import UIKit

class SearchDataCell: UITableViewCell {

    @IBOutlet weak var queueSongButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
