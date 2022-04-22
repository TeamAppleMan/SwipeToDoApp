//
//  SwipeCardViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import UIKit
import VerticalCardSwiper

class SwipeCardViewController: UIViewController {

    @IBOutlet var cardSwiper: VerticalCardSwiper!
    var catchTaskData: [Task] = []
    var cardTaskData: [Task] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        cardSwiper.register(nib:UINib(nibName: "CardViewCell", bundle: nil), forCellWithReuseIdentifier: "CardViewID")
        cardSwiper.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cardTaskData = catchTaskData
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // cardTaskDataのデータを前の画面に渡す（おそらくデリゲートを使う？）
    }

    @IBAction func tappedBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
extension SwipeCardViewController: VerticalCardSwiperDelegate,VerticalCardSwiperDatasource{
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        catchTaskData.count
    }

    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewID", for: index) as? CardViewCell {
            cardCell.setRandomBackgroundColor()
            // verticalCardSwiperView.backgroundColor = UIColor.random()
            verticalCardSwiperView.backgroundColor = .white
            cardCell.detailTextView.text = catchTaskData[index].detail
            // カテゴリー写真を暗くする
            cardCell.categoryPhotoImageView.image = cardCell.darkenCardViewCell(image: catchTaskData[index].photos!, level: 0.5)
            cardCell.categoryLabel.text = catchTaskData[index].category
            return cardCell
        }
        return CardCell()
    }


}
