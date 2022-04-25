//
//  SwipeCardViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import UIKit
import VerticalCardSwiper
import RealmSwift

protocol SwipeCardViewControllerDelegate{
    func catchDidSwipeCardData(catchTask: Results<Task>)
}

class SwipeCardViewController: UIViewController {

    @IBOutlet var cardSwiper: VerticalCardSwiper!
    var catchTask: Results<Task>!
    var cardTask: Results<Task>!
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
        cardTask = catchTask
    }

    @IBAction func tappedBackButton(_ sender: Any) {
        // cardTaskDataのデータを前の画面に渡す（おそらくデリゲートを使う？）
        delegate?.catchDidSwipeCardData(catchTask: cardTask)
        dismiss(animated: true)
    }
}
extension SwipeCardViewController: VerticalCardSwiperDelegate,VerticalCardSwiperDatasource{
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        catchTask.count
    }

    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewID", for: index) as? CardViewCell {
            cardCell.setRandomBackgroundColor()
            // verticalCardSwiperView.backgroundColor = UIColor.random()
            verticalCardSwiperView.backgroundColor = .white
            let object = cardTask[index]
            cardCell.detailTextView.text = object.detail
            // カテゴリー写真を暗くする
            cardCell.categoryPhotoImageView.image = cardCell.darkenCardViewCell(image: UIImage(data: object.photo!)!, level: 0.5)
            cardCell.categoryLabel.text = object.category
            return cardCell
        }
        return CardCell()
    }
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        if swipeDirection == .Right{
            let realm = try! Realm()
            // デリートではなく、isDoneをfalseからtrueにしてaddする
            try! realm.write{
                cardTask[index].isDone = true

            }
        }
    }
}
