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
import Pastel

protocol SwipeCardViewControllerDelegate{
    func catchDidSwipeCardData(catchTask: Results<Task>)
}

class SwipeCardViewController: UIViewController {

    @IBOutlet var cardSwiper: VerticalCardSwiper!
    @IBOutlet var pastelView: PastelView!

    private var cardTask: Results<Task>!
    public var catchTask: Results<Task>!
    var delegate: SwipeCardViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        cardSwiper.topInset = 25 // トップのViewの間隔
        cardSwiper.visibleNextCardHeight = 80 // 次にカードが見れ隠れする高さ
        cardSwiper.register(nib:UINib(nibName: "CardViewCell", bundle: nil), forCellWithReuseIdentifier: "CardViewID")
        cardSwiper.reloadData()
        setBackgroundColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        //フォアグラウンド時の処理
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SwipeCardViewController.viewWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // HACK: 正直cardTaskに格納する意味はないです。。笑
        cardTask = catchTask
    }
    //アプリがフォアグラウンド時(ホーム画面からアプリをタップした時でもBackgroundColorをパステルカラーにする
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            setBackgroundColor()
        }
    }

    // CalendarToDoViewControllerの画面遷移
//    @IBAction func tappedBackButton(_ sender: Any) {
//        // カードで更新したtaskデータをCalendarToDoViewControllerに渡し、tableViewをリロードするという意図があります
//        delegate?.catchDidSwipeCardData(catchTask: cardTask)
//        dismiss(animated: true)
//    }
    private func setBackgroundColor(){
        // Custom Direction
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight
        // 色変化の間隔[s]
        pastelView.animationDuration = 7.0

        // Custom Color
        pastelView.setColors([UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0),
                              UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)])
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
}
extension SwipeCardViewController: VerticalCardSwiperDelegate,VerticalCardSwiperDatasource{
    // カードの個数を返すデリゲートメソッド
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        cardTask.count
    }

    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewID", for: index) as? CardViewCell {
            verticalCardSwiperView.backgroundColor = .clear
            cardCell.configure(task: cardTask[index])
            return cardCell
        }
        return CardCell()
    }

    // スワイプした時に呼ばれるデリゲートメソッド
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        let realm = try! Realm()
        try! realm.write {
            cardTask[index].isDone = true
        }
        HUD.flash(.labeledSuccess(title: "やることSwipe", subtitle: "お疲れ様でした！"), delay: 0.5)
    }

}
