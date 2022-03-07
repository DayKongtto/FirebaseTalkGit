//
//  DestinationMessageCell.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/05.
//

import UIKit

class DestinationMessageCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var messageLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
