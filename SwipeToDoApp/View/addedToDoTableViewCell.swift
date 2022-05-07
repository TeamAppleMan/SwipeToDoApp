//
//  addedToDoTableViewCell.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit

class addedToDoTableViewCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var notCheckImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func congifure(detail: String, category: String, isDone: Bool) {
        detailLabel.text = detail
        categoryLabel.text = 
        
    }
    
}
