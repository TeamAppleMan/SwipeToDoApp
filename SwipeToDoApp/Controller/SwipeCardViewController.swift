//
//  SwipeCardViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import UIKit
import VerticalCardSwiper

protocol SwipeCardViewControllerDelegate{
    func catchDidSwipeCardData(catchTask: [Task])
}

class SwipeCardViewController: UIViewController {

    @IBOutlet var cardSwiper: VerticalCardSwiper!
    var catchTaskData: [Task] = []
    var cardTaskData: [Task] = []
    var delegate: SwipeCardViewControllerDelegate?

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

    @IBAction func tappedBackButton(_ sender: Any) {
        // cardTaskDataのデータを前の画面に渡す（おそらくデリゲートを使う？）
        delegate?.catchDidSwipeCardData(catchTask: cardTaskData)
        dismiss(animated: true)
    }
}
extension SwipeCardViewController: VerticalCardSwiperDelegate,VerticalCardSwiperDatasource{
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        cardTaskData.count
    }

    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewID", for: index) as? CardViewCell {
            cardCell.setRandomBackgroundColor()
            // verticalCardSwiperView.backgroundColor = UIColor.random()
            verticalCardSwiperView.backgroundColor = .white
            cardCell.detailTextView.text = cardTaskData[index].detail
            // カテゴリー写真を暗くする
//            cardCell.categoryPhotoImageView.image = cardCell.darkenCardViewCell(image: cardTaskData[index].photos!, level: 0.5)
            cardCell.categoryLabel.text = cardTaskData[index].category
            return cardCell
        }
        return CardCell()
    }
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        if swipeDirection == .Right{
            cardTaskData.remove(at: index)
        }
    }


}
