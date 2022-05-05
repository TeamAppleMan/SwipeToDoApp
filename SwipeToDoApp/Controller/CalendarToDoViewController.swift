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

    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private(set) weak var tableView: UITableView! // CategoryListViewControllerがアクセスするためprivate(set)にした
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var beforeDayButton: UIButton!
    @IBOutlet private weak var afterDayButton: UIButton!
    @IBOutlet private weak var addTaskTextField: UITextField!
    @IBOutlet private weak var taskCardView: UIView!
    @IBOutlet private weak var taskCardTitleLabel: UILabel!
    @IBOutlet private weak var addTaskButton: UIButton!
    @IBOutlet private weak var swipeTaskButton: UIButton!

    private var task: Results<Task>!
    private var filtersTask: Results<Task>!
    private var categoryList: Results<CategoryList>!
    private var selectedDate: Date!


    override func loadView() {
        super.loadView()
        print("aaa")
        // Lottieを表示するか否かの判定
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunchKey"

        if !userDefaults.bool(forKey: firstLunchKey) {
            print(userDefaults.bool(forKey: firstLunchKey))
            let navigationController = storyboard?.instantiateViewController(withIdentifier: "LottieNavigationController") as! UINavigationController
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addTaskTextField.delegate = self
        // RealmのファイルURLを表示する
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        let realm = try! Realm()
        task = realm.objects(Task.self)

        addTaskButton.isEnabled = false
        tableView.allowsSelection = false
        setCalendar()
        setTableView()
        setView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addTaskTextField.isEnabled = true
    }

    // HACK: if文が連結していてあまり良い書き方ではない
    // →「guard let」を使うことで解決しました！（Kota）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SwipeCardSegue" {
            let nav = segue.destination as! UINavigationController
            let swipeCardVC = nav.topViewController as! SwipeCardViewController
            swipeCardVC.delegate = self
            // realmで保存されたtaskの中から、(年、月、日付情報が選択された&&isDoneがfalse)であるtaskをフィルタリングして、swipeCardVCに渡す
            let realm = try! Realm()
            let filtersTask = realm.objects(Task.self).filter("date==%@ && isDone==%@", selectedDate!, false)
            swipeCardVC.catchTask = filtersTask
        }

        if segue.identifier == "NavVCSegue" {
            guard let inputTask = addTaskTextField.text, !inputTask.isEmpty else {
                return
            }
            let nav = segue.destination as! UINavigationController
            guard let sheet = nav.sheetPresentationController  else { return }
            let inputCategoryVC = nav.topViewController as! InputCategoryViewController
            inputCategoryVC.catchTask = addTaskTextField.text ?? ""
            sheet.detents = [.medium()]
            //モーダル出現後も親ビュー操作不可能にする
            sheet.largestUndimmedDetentIdentifier = .large
            // 角丸の半径
            sheet.preferredCornerRadius = 20.0
            // 上の灰色のバー
            sheet.prefersGrabberVisible = true
        }

    }

    @IBAction private func didTapBeforeDayButton(_ sender: Any) {
        selectedDate = selectedDate.added(year: 0, month: 0, day: -1, hour: 0, minute: 0, second: 0)
        dateLabel.text = "    \(selectedDate.year)年\(selectedDate.month)月\(selectedDate.day)日"
        tableView.reloadData()
        setCalendarDate(date: selectedDate)
    }

    @IBAction private func didTapAfterDayButton(_ sender: Any) {
        selectedDate = selectedDate.added(year: 0, month: 0, day: 1, hour: 0, minute: 0, second: 0)
        dateLabel.text = "    \(selectedDate.year)年\(selectedDate.month)月\(selectedDate.day)日"
        tableView.reloadData()
        setCalendarDate(date: selectedDate)
    }

    @IBAction private func didTapAddButton(_ sender: Any) {
        // 文字を選択しながらモーダル遷移した場合挙動が不自然に変わる対処
        addTaskTextField.isEnabled = false
        performSegue(withIdentifier: "NavVCSegue", sender: nil)
        addTaskTextField.isEnabled = true
    }

    @IBAction private func taskDeleteButton(_ sender: Any) {
        // SwipeCardVCへ画面遷移
        // taskTextField.isEnabledがtrueだとモーダル遷移もしてしまうため
        // addTaskTextField.isEnabled = false
        performSegue(withIdentifier: "SwipeCardSegue", sender: nil)
    }

    // textFieldに文字が入力されていればボタンを表示する
    @IBAction func changedTextField(_ sender: Any) {
        if addTaskTextField.text == "" {
            addTaskButton.isEnabled = false
        } else {
            addTaskButton.isEnabled = true
        }
    }

    private func setView() {
        beforeDayButton.layer.borderColor = UIColor.darkGray.cgColor
        beforeDayButton.layer.borderWidth = 1.0
        beforeDayButton.layer.cornerRadius = 8.0
        afterDayButton.layer.borderColor = UIColor.darkGray.cgColor
        afterDayButton.layer.borderWidth = 1.0
        afterDayButton.layer.cornerRadius = 8.0
        taskCardView.layer.cornerRadius = 10
        taskCardView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        taskCardView.layer.shadowColor = UIColor.black.cgColor
        taskCardView.layer.shadowOpacity = 0.4
        taskCardView.layer.shadowRadius = 3
        taskCardTitleLabel.clipsToBounds = true
        taskCardTitleLabel.layer.cornerRadius = 10
        taskCardTitleLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        swipeTaskButton.layer.cornerRadius = 5
    }

    // HACK:  setCalendarと内容が被っている。冗長になってしまっている。Dateのextensionを使用すればもう少し短くなるかも
    private func setCalendar() {
        calendar.delegate = self
        calendar.scope = .month
        calendar.locale = Locale(identifier: "ja")
        calendar.locale  = .current
        //現在の年・月・日・時刻を取得
        // なぜ下でうまくいくのかさっぱりわからない。
        selectedDate = Date()
        selectedDate = selectedDate.added(year: 0, month: 0, day: 0, hour: 9, minute: 0, second: 0)
        selectedDate = selectedDate.fixed(year: selectedDate.year, month: selectedDate.month, day: selectedDate.day, hour: 15, minute: 00, second: 00).added(year: 0, month: 0, day: 0, hour: 9, minute: 0, second: 0)
        setCalendarDate(date: selectedDate)
        dateLabel.text = "    \(selectedDate.year)年\(selectedDate.month)月\(selectedDate.day)日"
    }

    private func setTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.register(UINib(nibName: "addedToDoTableViewCell", bundle: nil), forCellReuseIdentifier: "addedToDoID")
    }

    // 余白タッチでキーボード収納
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func exitCancel(segue: UIStoryboardSegue){
    }

    private func setCalendarDate(date: Date) {
        calendar.select(date.added(year:0, month:0, day:-1, hour:0, minute:0, second:0))
    }

    private func getCalendarDate() -> Date {
        calendar.selectedDate!.added(year: 0, month: 0, day: 1, hour: 0, minute: 0, second: 0)
    }

    @IBAction func exitSave(segue: UIStoryboardSegue){
        print("saveButton")
        let inputCategoryVC = segue.source as! InputCategoryViewController
        let selectedIndexNumber = inputCategoryVC.selectedIndexNumber
        let realm = try! Realm()
        categoryList = realm.objects(CategoryList.self)
        // 新しいタスクの初期化（isRepeatedとisDoneはfalseにしている）
        let newTask = Task.init(value: ["date": selectedDate!, "detail": addTaskTextField.text ?? "", "category": categoryList[selectedIndexNumber].name, "isRepeated": false, "isDone": false, "photo": categoryList[selectedIndexNumber].photo!])
        try! realm.write{
            realm.add(newTask)
        }
        addTaskTextField.text = ""
        addTaskButton.isEnabled = false
        // 追加されたTaskをtableViewに反映するために、tableView.reloadData()している
        tableView.reloadData()
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
        selectedDate = getCalendarDate()
        dateLabel.text = "    \(selectedDate.year)年\(selectedDate.month)月\(selectedDate.day)日"
        tableView.reloadData()
    }

}

extension CalendarToDoViewController: UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // HACK: realmで保存されたtaskの中から、(年、月、日付情報が選択された)であるtaskをフィルタリングしてtableViewに反映
        let realm = try! Realm()
        filtersTask = realm.objects(Task.self).filter("date==%@", selectedDate!, false)
        return filtersTask.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // HACK: realmで保存されたtaskの中から、(年、月、日付情報が選択された&&isDoneがfalse)であるtaskをフィルタリングしてtableViewに反映
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedToDoID", for: indexPath) as! addedToDoTableViewCell
        let object = filtersTask[indexPath.row]
        cell.detailLabel.text = object.detail
        cell.categoryLabel.text = object.category
        cell.checkImage.isHidden = !object.isDone
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            try! realm.write{
                let object = filtersTask[indexPath.row]
                realm.delete(object)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension CalendarToDoViewController: SwipeCardViewControllerDelegate{
    // SwipeCardViewControllerのデリゲートメソッド: バックボタンを押した時に呼ばれる
    func catchDidSwipeCardData(catchTask: Results<Task>) {
        task = catchTask
        tableView.reloadData()
    }
}
