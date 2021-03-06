//
//  LeagueTableViewCell.swift
//  FriendlyFanduel
//
//  Created by Kurt Jensen on 3/3/16.
//  Copyright © 2016 Arbor Apps LLC. All rights reserved.
//

import UIKit
import SDWebImage

class LeagueTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var leagueImageView: UIImageView!
    
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
        leagueImageView.sd_cancelCurrentImageLoad()
    }
    
    func configureWithLeague(league: PFLeague) {
        nameLabel.text = league.name
        descriptionLabel.text = league.tagline
        if let imageURL = league.imageURL, let url = NSURL(string: imageURL) {
            leagueImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "Trophy-104-Green"))
        }
    }

}
