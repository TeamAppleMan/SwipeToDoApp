//
//  CardViewCell2.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/05/04.
//

import UIKit
import VerticalCardSwiper

class CardViewCell: CardCell {

    @IBOutlet private weak var categoryPhotoImageView: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var detailTextView: UITextView!
    @IBOutlet private weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        categoryPhotoImageView.layer.cornerRadius = 12
    }

    func configure(task: Task!) {
        // タスクのカテゴリがnilだったら「未カテゴリ画像」を表示させる
        if let category = task.category, category.image != nil {
            categoryPhotoImageView.image = darkenCardViewCell(image: UIImage(data: category.image)!, level: 0.5)
            categoryLabel.text = category.name
            dateLabel.text = "  \(task.date.year)年\(task.date.month)月\(task.date.day)日"
            detailTextView.text = task.detail
        } else {
            categoryPhotoImageView.image = darkenCardViewCell(image: UIImage(named: "ハテナ")!, level: 0.5)
            categoryLabel.text = "未カテゴリ"
            dateLabel.text = "  \(task.date.year)年\(task.date.month)月\(task.date.day)日"
            detailTextView.text = task.detail
        }

    }

    // ライブラリのコードからそのまま拝借
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // ライブラリのコードからそのまま拝借
    override func layoutSubviews() {
        self.layer.cornerRadius = 12
    }

    // ライブラリのコードからそのまま拝借
    private func setRandomBackgroundColor() {
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

    // 背景色を暗くフィルターをかける
    private func darkenCardViewCell(image: UIImage, level: CGFloat) -> UIImage {
        // 一時的な暗くするようの黒レイヤ
        let frame = CGRect(origin:CGPoint(x:0,y:0),size:image.size)
        let tempView = UIView(frame:frame)
        tempView.backgroundColor = UIColor.black
        tempView.alpha = level

        // 画像を新しいコンテキストに描画する
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        image.draw(in: frame)

        // コンテキストに黒レイヤを乗せてレンダー
        context!.translateBy(x: 0, y: frame.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.clip(to: frame, mask: image.cgImage!)
        tempView.layer.render(in: context!)

        let imageRef = context!.makeImage()
        let toReturn = UIImage(cgImage:imageRef!)
        UIGraphicsEndImageContext()
        return toReturn
    }

}

