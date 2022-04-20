//
//  addedToDoTableViewCell.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit

class addedToDoTableViewCell: UITableViewCell {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
