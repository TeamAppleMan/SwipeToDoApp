//
//  CardViewCell.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import UIKit
import VerticalCardSwiper

class CardViewCell: CardCell {

    @IBOutlet var categoryPhotoImageView: UIImageView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var detailTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryLabel.textColor = .white
        detailTextView.textColor = .white
        // 写真を角丸に設定
        categoryPhotoImageView.layer.cornerRadius = 12
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
    public func setRandomBackgroundColor() {
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    // 背景色を暗くフィルターをかける
    public func darkenCardViewCell(image:UIImage, level:CGFloat) -> UIImage {
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
