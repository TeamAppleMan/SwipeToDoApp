//
//  SwipeCardViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import UIKit
import VerticalCardSwiper
import RealmSwift
import PKHUD

protocol SwipeCardViewControllerDelegate{
    func catchDidSwipeCardData(catchTask: Results<Task>)
}

class SwipeCardViewController: UIViewController {

    @IBOutlet var cardSwiper: VerticalCardSwiper!
    
    private var cardTask: Results<Task>!
    public var catchTask: Results<Task>!
    public var catchDate: Date?

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
        // HACK: 正直cardTaskに格納する意味はないです。。笑
        cardTask = catchTask
        guard let catchDate = catchDate else {
            return
        }
        navigationItem.title = "\(catchDate.year)年\(catchDate.month)月\(catchDate.day)日"
    }

    // CalendarToDoViewControllerの画面遷移

    @IBAction func tappedBackButton(_ sender: Any) {
        // カードで更新したtaskデータをCalendarToDoViewControllerに渡し、tableViewをリロードするという意図があります
        delegate?.catchDidSwipeCardData(catchTask: cardTask)
        dismiss(animated: true)
    }
}
extension SwipeCardViewController: VerticalCardSwiperDelegate,VerticalCardSwiperDatasource{
    // カードの個数を返すデリゲートメソッド
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        cardTask.count
    }

    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewID", for: index) as? CardViewCell {
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
    // 右スワイプした時に呼ばれるデリゲートメソッド
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        if swipeDirection == .Right{
            // 右スワイプしたタスクデータはisDoneをfalseにしてRealmに登録
            let realm = try! Realm()
            try! realm.write{
                cardTask[index].isDone = true
            }
            HUD.flash(.labeledSuccess(title: "タスク消化", subtitle: "お疲れ様でした...！"), delay: 0.5)
        }else if swipeDirection == .Left{
            HUD.flash(.labeledError(title: "無効", subtitle: "この操作は現在無効です"), delay: 0.5)
        }
    }
}
