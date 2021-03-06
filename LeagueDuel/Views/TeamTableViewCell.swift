//
//  TeamTableViewCell.swift
//  LeagueDuel
//
//  Created by Kurt Jensen on 3/25/16.
//  Copyright © 2016 Arbor Apps LLC. All rights reserved.
//

import UIKit
import SDWebImage

class TeamTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var leagueLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.borderColor = UIColor.lightGrayColor().CGColor
        bgView.layer.borderWidth = 0.5
        bgView.layer.shadowRadius = 4
        bgView.layer.shadowOpacity = 0.4
        bgView.layer.shadowOffset = CGSizeMake(0,1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        teamImageView.sd_cancelCurrentImageLoad()
    }
    
    func configureWithDuelTeam(duelTeam: PFDuelTeam, showLeague: Bool) {
        nameLabel.text = duelTeam.name
        if let imageURL = duelTeam.imageURL, let url = NSURL(string: imageURL) {
            teamImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named:"Team-96"))
        }
        if (showLeague) {
            leagueLabel.text = duelTeam.league.name
        } else {
            leagueLabel.text = nil
        }
    }

    
}
