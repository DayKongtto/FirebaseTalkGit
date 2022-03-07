//
//  PeopleViewCell.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/06.
//

import UIKit
import SnapKit

class PeopleViewCell: UITableViewCell {
    
    var imageview: UIImageView? = UIImageView()
    var label: UILabel? = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if let imageview = imageview {
            self.addSubview(imageview)
        }
        if let label = label {
            self.addSubview(label)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
