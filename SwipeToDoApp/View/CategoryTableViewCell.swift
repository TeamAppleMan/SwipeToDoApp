//
//  CategoryTableViewCell.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/22.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView?
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryTaskCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setCircleImageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    private func setCircleImageView() {
        // ImageViewを円形にする
        categoryImageView?.layer.cornerRadius = (categoryImageView?.frame.width ?? CGFloat(200)) / 2
        categoryImageView?.clipsToBounds = true
    }
    
}
