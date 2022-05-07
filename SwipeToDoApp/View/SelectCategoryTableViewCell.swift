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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setCategoryImage() {
        imagePhoto.contentMode = .scaleAspectFill
        imagePhoto.layer.cornerRadius = imagePhoto.frame.width/2
        imagePhoto.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setCategoryImage()
    }

    // カプセル化
    func configure(imagePhoto: Data, name: String) {
        self.imagePhoto.image = UIImage(data: imagePhoto)
        self.name.text = name
    }

}
