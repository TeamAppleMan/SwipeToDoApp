//
//  SelectCategoryTableViewCell.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/05/07.
//

import UIKit

class SelectCategoryTableViewCell: UITableViewCell {

    @IBOutlet private weak var imagePhoto: UIImageView!
    @IBOutlet private weak var name: UILabel!

    // カプセル化
    func configure(imagePhoto: UIImage, name: String) {
        self.imagePhoto.image = imagePhoto
        self.name.text = name
        self.imagePhoto.layer.cornerRadius = self.imagePhoto.frame.width/2
        self.imagePhoto.clipsToBounds = true
    }

}
