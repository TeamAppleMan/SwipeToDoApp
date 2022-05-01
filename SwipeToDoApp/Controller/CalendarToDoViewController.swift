//
//  ViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import FSCalendar
import MaterialComponents
import RealmSwift

class CalendarToDoViewController: UIViewController {

    @IBOutlet private var calendar: FSCalendar!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var taskTextField: MDCOutlinedTextField!
    @IBOutlet private var dateLabel: UILabel!

    private var task: Results<Task>!
    private var categoryList: Results<CategoryList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // RealmのファイルURLを表示する
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        let realm = try! Realm()
        task = realm.objects(Task.self) // Taskの保存
        setTableView()
        setCalendar()
        setTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setInitCalendar()
        tableView.reloadData()
    }

    // HACK: setCalendarと内容が少し被ってしまっている。少し冗長になってしまっている。前田さん作のDateのextensionを使用すればもう少し短くなるかも？？。
    private func setInitCalendar(){
        // 最新で選択したカレンダーの日付をデフォルトで選択された状態にする。（スワイプ画面から戻ってきたときこの方が自然だから）
        if UserDefaults.standard.object(forKey: "selectedDateKey") != nil{
            calendar.select(UserDefaults.standard.object(forKey: "selectedDateKey") as! Date)
        }else{
            let calPosition = Calendar.current
            // 現在の年・月・日・時刻を取得
            let comp = calPosition.dateComponents(
                [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,
                 Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second],
                 from: Date())
            let selectDay = calPosition.date(from: DateComponents(year: comp.year, month: comp.month, day: comp.day))
            calendar.select(selectDay)
        }
    }

    // HACK: if文が連結していてあまり良い書き方ではない
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // セミモーダルへの画面遷移
        if segue.identifier == "NavVCSegue"{
            let nav = segue.destination as! UINavigationController
            if let sheet = nav.sheetPresentationController {
                let inputCategoryVC = nav.topViewController as! InputCategoryViewController
                inputCategoryVC.catchTask = taskTextField.text ?? "aaa"
                sheet.detents = [.medium()]
                //モーダル出現後も親ビュー操作可能にする
                sheet.largestUndimmedDetentIdentifier = .medium
                // 角丸の半径を変更する
                sheet.preferredCornerRadius = 20.0
                //　グラバーを表示する（上の灰色のバー）
                sheet.prefersGrabberVisible = true
            }
        }else if segue.identifier == "SwipeCardSegue"{
            let nav = segue.destination as! UINavigationController
            let swipeCardVC = nav.topViewController as! SwipeCardViewController
            // ナビゲーションバータイトル用に、選択された日付を渡す
            if UserDefaults.standard.object(forKey: "selectedDateKey") != nil{
                swipeCardVC.catchDate =  UserDefaults.standard.object(forKey: "selectedDateKey") as? Date
            }
            swipeCardVC.delegate = self

            // realmで保存されたtaskの中から、(年、月、日付情報が選択された&&isDoneがfalse)であるtaskをフィルタリングして、swipeCardVCに渡す
            let realm = try! Realm()
            guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
                return
            }
            let filtersTask = try! realm.objects(Task.self).filter("date==%@ && isDone==%@",nowSelectedDate,false)
            swipeCardVC.catchTask = filtersTask
        }
    }

    // モーダル遷移先のCancelButtonを押すと、帰ってくる処理
    @IBAction func exitCancel(segue: UIStoryboardSegue){
    }

    @IBAction func exitSave(segue: UIStoryboardSegue){
        print("saveButton")
        let inputCategoryVC = segue.source as! InputCategoryViewController

        let selectedIndexNumber = inputCategoryVC.selectedIndexNumber

        guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return
        }
        let realm = try! Realm()
        categoryList = realm.objects(CategoryList.self)
        // 新しいタスクの初期化（isRepeatedとisDoneはfalseにしている）
        let newTodo = Task.init(value: ["date": nowSelectedDate,"detail": taskTextField.text ?? "","category": categoryList[selectedIndexNumber].name,"isRepeated": false,"isDone": false,"photo": categoryList[selectedIndexNumber].photo!])
        try! realm.write{
            realm.add(newTodo)
        }
        taskTextField.text = ""
        // 追加されたTaskをtableViewに反映するために、tableView.reloadData()している
        tableView.reloadData()
    }

    @IBAction private func taskDeleteButton(_ sender: Any) {
        // SwipeCardVCへ画面遷移
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
        tableView.rowHeight = 80
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
        // 選択されたカレンダーの日付ごとに、TableViewの表示を変更するためのtableView.reloadData()
        tableView.reloadData()
        let calPosition = Calendar.current
        guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return
        }
        // Swipe画面から戻ってきた時にカレンダーの選択をselectedDateにするためにselectedDateを保存
        UserDefaults.standard.set(selectedDate,forKey: "selectedDateKey")
        let comp = calPosition.dateComponents( [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date)

        taskTextField.placeholder = "\(comp.month!)月\(comp.day!)日のタスクを追加"
        dateLabel.text = "\(comp.year!)年\(comp.month!)月\(comp.day!)日"
    }
}
extension CalendarToDoViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // HACK: realmで保存されたtaskの中から、(年、月、日付情報が選択された&&isDoneがfalse)であるtaskをフィルタリングしてtableViewに反映
        let realm = try! Realm()
        guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return 0
        }
        let filtersTask = try! realm.objects(Task.self).filter("date==%@ && isDone==%@",nowSelectedDate,false)
        return filtersTask.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // HACK: realmで保存されたtaskの中から、(年、月、日付情報が選択された&&isDoneがfalse)であるtaskをフィルタリングしてtableViewに反映
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedToDoID", for: indexPath) as! addedToDoTableViewCell
        // 日付レベルでフィルタリング
        let realm = try! Realm()
        guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return cell
        }
        let filtersTask = try! realm.objects(Task.self).filter("date==%@ && isDone==%@",nowSelectedDate,false)
        let object = filtersTask[indexPath.row]
        cell.detailLabel.text = object.detail
        cell.categoryLabel.text = object.category
        return cell
    }
}

extension CalendarToDoViewController: SwipeCardViewControllerDelegate{
    // SwipeCardViewControllerのデリゲートメソッド: バックボタンを押した時に呼ばれる
    func catchDidSwipeCardData(catchTask: Results<Task>) {
        task = catchTask
        tableView.reloadData()
    }
}

