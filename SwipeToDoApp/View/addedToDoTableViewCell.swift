//
//  addedToDoTableViewCell.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit

class addedToDoTableViewCell: UITableViewCell {

    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var checkImage: UIImageView!
    @IBOutlet private weak var notCheckImage: UIImageView!

    func congifure(detail: String, categoryName: String, isDone: Bool) {
        detailLabel.text = detail
        categoryLabel.text = categoryName
        checkImage.isHidden = !isDone
        notCheckImage.isHidden = isDone
    }

}
