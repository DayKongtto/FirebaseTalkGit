//
//  RowCell.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/07.
//

import UIKit

class RowCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var lastMessageLabel: UILabel?
    @IBOutlet weak var imageview: UIImageView?
    @IBOutlet weak var timestampLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
