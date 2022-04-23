//
//  ViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import FSCalendar
import MaterialComponents

class CalendarToDoViewController: UIViewController, SwipeCardViewControllerDelegate {


    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var taskTextField: MDCOutlinedTextField!
    @IBOutlet var dateLabel: UILabel!

    private var searchTasks: [Task]? = []
    private var taskDatas: [Task]? = []
    var categoryList: [CategoryList] = [CategoryList.init(categories: "運動", photos: UIImage(named: "manran")),CategoryList.init(categories: "プログラミング", photos: UIImage(named: "programming")),CategoryList.init(categories: "買い物", photos: UIImage(named: "shopping")),CategoryList.init(categories: "会議", photos: UIImage(named: "mtg"))]

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setCalendar()
        setTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        taskDatas = JsonEncoder.readItemsFromUserUserDefault(key: "searchTasksKey")
        tableView.reloadData()
    }

    // HACK: if文が連結していてあまり良い書き方ではない
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // セミモーダルへの画面遷移
        if segue.identifier == "NavVCSegue"{
            let nav = segue.destination as! UINavigationController
            if let sheet = nav.sheetPresentationController {
                let inputCategoryVC = nav.topViewController as! InputCategoryViewController
                inputCategoryVC.task = taskTextField.text ?? "aaa"
                sheet.detents = [.medium()]
                //モーダル出現後も親ビュー操作可能にする
                sheet.largestUndimmedDetentIdentifier = .medium
                // 角丸の半径を変更する
                sheet.preferredCornerRadius = 20.0
                //　グラバーを表示する（上の灰色のバー）
                sheet.prefersGrabberVisible = true
            }
        }else if segue.identifier == "SwipeCardSegue"{
            // 保存したタスクデータを渡すorUserDefalutsで保存する？
            let swipeCardVC = segue.destination as! SwipeCardViewController
            swipeCardVC.delegate = self
            swipeCardVC.catchTaskData = searchTasks ?? []
        }
    }

    // SwipeCardViewControllerによるデリゲートメソッド。Swipe後のデータをTableViewに反映
    func catchDidSwipeCardData(catchTask: [Task]) {
        taskDatas = catchTask
        tableView.reloadData()
    }

    // モーダル遷移先のCancelButtonを押すと、帰ってくる処理
    @IBAction func exitCancel(segue: UIStoryboardSegue){
    }

    @IBAction func exitSave(segue: UIStoryboardSegue){
        print("saveButton")
        let inputCategoryVC = segue.source as! InputCategoryViewController

        let selectedIndexNumber = inputCategoryVC.selectedIndexNumber
        // カレンダーデータのオプショナルバインディング
        guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return
        }
        print("selectedIndexNumber:",selectedIndexNumber)
        taskDatas?.append(.init(date: nowSelectedDate, detail: taskTextField.text ?? "", category: categoryList[selectedIndexNumber].categories, isRepeatedTodo: false, isDone: false, photos: categoryList[selectedIndexNumber].photos!))
        print("taskDatas: ",taskDatas!)

        taskTextField.text = ""
        tableView.reloadData()
    }

    // SwipeCardVCへ画面遷移
    @IBAction func taskDeleteButton(_ sender: Any) {
        performSegue(withIdentifier: "SwipeCardSegue", sender: nil)
    }

    private func setCalendar(){
        calendar.delegate = self
        calendar.scope = .week
        calendar.locale = Locale(identifier: "ja")
        // 現在の国を取得（場所によって現在時刻が変わるため）
        let calPosition = Calendar.current
        // 現在の年・月・日・時刻を取得
        let comp = calPosition.dateComponents(
            [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,
             Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second],
             from: Date())
        // 動くテキストフィールドに取得した日時を表示
        taskTextField.placeholder = "\(comp.month!)月\(comp.day!)日のタスクを追加"
        dateLabel.text = "\(comp.year!)年\(comp.month!)月\(comp.day!)日"
    }

    private func setTextField(){
        taskTextField.delegate = self
        taskTextField.label.text = "追加するタスクを入力"
        // TextFieldが選択されていない状態の枠と文字の色
        taskTextField.setOutlineColor(.gray, for: .normal)
        taskTextField.setFloatingLabelColor(.gray, for: .normal)

        // 編集中の枠と文字の色
        taskTextField.setNormalLabelColor(.gray, for: .normal)
        taskTextField.setOutlineColor(.blue, for: .editing)
        taskTextField.setFloatingLabelColor(.blue, for: .editing)
    }

    private func setTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "addedToDoTableViewCell", bundle: nil), forCellReuseIdentifier: "addedToDoID")
    }

    // 余白タッチでキーボード収納
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

extension CalendarToDoViewController: UITextFieldDelegate {
    // Returnボタンでキーボード収納
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension CalendarToDoViewController: FSCalendarDelegate {
    // カレンダーの日付をタップした時に、カードに日付情報を反映させる処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        tableView.reloadData()
        let calPosition = Calendar.current
        let comp = calPosition.dateComponents( [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date)
        taskTextField.placeholder = "\(comp.month!)月\(comp.day!)日のタスクを追加"
        dateLabel.text = "\(comp.year!)年\(comp.month!)月\(comp.day!)日"
    }
}
extension CalendarToDoViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchTasks = []
        // 現在選択されたデータの取得。なぜか１日ずれるため１日ずらす
        guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return taskDatas?.count ?? 0
        }
        // 配列の中から選択された同じ日付のデータが存在するかを調べて、あればsearchTasksに追加
        searchTasks = taskDatas?.filter {
            $0.date ==  nowSelectedDate
        }
        // アプリ内保存
        JsonEncoder.saveItemsToUserDefaults(list: taskDatas!, key: "searchTasksKey")
        return searchTasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        searchTasks = JsonEncoder.readItemsFromUserUserDefault(key: "searchTasksKey")
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedToDoID", for: indexPath) as! addedToDoTableViewCell
        cell.detailLabel.text = searchTasks![indexPath.row].detail
        cell.categoryLabel.text = searchTasks![indexPath.row].category
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

