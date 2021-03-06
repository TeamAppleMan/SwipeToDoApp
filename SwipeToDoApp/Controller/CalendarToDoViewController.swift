//
//  ViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import FSCalendar
import RealmSwift

class CalendarToDoViewController: UIViewController, InputCategoryViewControllerDelegate {

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

    private var tasks: Results<Task>!
    private var filtersTask: Results<Task>!
    private var categoryList: Results<Category>!
    private var selectedDate: Date!
    private var editGiveTask: Task?
    private var list: List<Category>!
    private var index = 0
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        addTaskTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // RealmのファイルURLを表示する
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        let realm = try! Realm()
        tasks = realm.objects(Task.self)
        list = realm.objects(CategoryLists.self).first?.list

        addTaskButton.isEnabled = false
        tableView.allowsSelection = true
        setCalendar()
        setTableView()
        setView()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Lottieを表示するか否かの判定
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunchKey"
        if !userDefaults.bool(forKey: firstLunchKey) {
            if let lottieNC = storyboard?.instantiateViewController(withIdentifier: "LottieNvigationController") as? UINavigationController,
                       let _ = lottieNC.topViewController as? Lottie01ViewController {
                present(lottieNC, animated: true, completion: nil)
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        addTaskTextField.isEnabled = true
        let realm = try! Realm()
        tasks = realm.objects(Task.self)
        categoryList = realm.objects(Category.self)
        calendar.reloadData()
        tableView.reloadData()
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let noneMoveHeight = view.frame.origin.y + view.frame.size.height - keyboardSize.height
        let textFieldMidY = taskCardView.frame.origin.y + addTaskTextField.frame.origin.y + addTaskTextField.frame.size.height

        if noneMoveHeight <= textFieldMidY {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= textFieldMidY - noneMoveHeight + 25
            }
        } else {
            print("キーボードを動かす必要なし")
        }

    }

    @objc func keyboardWillHide(notification: NSNotification) {

        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }

    }

    // HACK: if文が連結していてあまり良い書き方ではない
    // →「guard let」を使うことで解決しました！（Kota）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SwipeCardSegue" {
            let swipeCardVC = segue.destination as! SwipeCardViewController
            swipeCardVC.delegate = self
            // realmで保存されたtaskの中から、(年、月、日付情報が選択された&&isDoneがfalse)であるtaskをフィルタリングして、swipeCardVCに渡す
            let realm = try! Realm()
            let filtersTask = realm.objects(Task.self).filter("date==%@ && isDone==%@", getCalendarDate(), false)
            swipeCardVC.configureFromCalendarVC(swipeTask: filtersTask)
        }

        if segue.identifier == "NavVCSegue" {
            guard let inputTask = addTaskTextField.text, !inputTask.isEmpty else {
                return
            }
            let nav = segue.destination as! UINavigationController
            guard let sheet = nav.sheetPresentationController  else { return }
            let inputCategoryVC = nav.topViewController as! InputCategoryViewController
            inputCategoryVC.delegate = self

            let text = addTaskTextField.text ?? ""
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            inputCategoryVC.configure(task: trimmedText)
            sheet.detents = [.medium()]
            //モーダル出現後も親ビュー操作不可能にする
            sheet.largestUndimmedDetentIdentifier = .large
            // 角丸の半径
            sheet.preferredCornerRadius = 20.0
            // 上の灰色のバー
            sheet.prefersGrabberVisible = true
        }

        if segue.identifier == "EditSegue" {
            let nextVC = segue.destination as! TaskEditViewController
            nextVC.configure(task: editGiveTask!, tasks: filtersTask, index: index)
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

    // SwipeCardVCへ画面遷移
    @IBAction private func taskDeleteButton(_ sender: Any) {
        hidesBottomBarWhenPushed = true
        performSegue(withIdentifier: "SwipeCardSegue", sender: nil)
        hidesBottomBarWhenPushed = false
    }

    // textFieldに文字が入力されていればボタンを表示する
    @IBAction func changedTextField(_ sender: Any) {
        let text = addTaskTextField.text ?? ""
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty {
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
        taskCardView.layer.cornerRadius = 12
        taskCardView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        taskCardView.layer.shadowColor = UIColor.black.cgColor
        taskCardView.layer.shadowOpacity = 0.4
        taskCardView.layer.shadowRadius = 3
        taskCardTitleLabel.clipsToBounds = true
        taskCardTitleLabel.layer.cornerRadius = 12
        taskCardTitleLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        swipeTaskButton.layer.cornerRadius = 12
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

    func addNewDate(detail: String, category: Category?) {
        let realm = try! Realm()
        let newTask = Task.init(value: ["date": selectedDate!, "detail": detail, "category": category ?? nil, "isRepeated": false, "isDone": false])

        try! realm.write{
            realm.add(newTask)
        }

        addTaskTextField.text = ""
        addTaskButton.isEnabled = false
        tableView.reloadData()
        calendar.reloadData()
    }

}

extension CalendarToDoViewController: UITextFieldDelegate {

    // Returnボタンでキーボード収納
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension CalendarToDoViewController: FSCalendarDelegate, FSCalendarDataSource {

    // カレンダーの日付をタップした時に、カードに日付情報を反映させる処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = getCalendarDate()
        dateLabel.text = "    \(selectedDate.year)年\(selectedDate.month)月\(selectedDate.day)日"
        tableView.reloadData()
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        // FSCalendarの表示がなぜか１日前なので、ズラス。
        let fixdate = date.added(year: 0, month: 0, day: 1, hour: 0, minute: 0, second: 0)

        let filterTasks = tasks.filter {
            $0.date == fixdate && $0.isDone == false
        }

        if filterTasks.isEmpty {
            return 0
        } else {
            return 1
        }
    }

}

extension CalendarToDoViewController: UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        filtersTask = realm.objects(Task.self).filter("date==%@", selectedDate!, false)
        return filtersTask.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // HACK: realmで保存されたtaskの中から、(年、月、日付情報が選択された&&isDoneがfalse)であるtaskをフィルタリングしてtableViewに反映
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedToDoID", for: indexPath) as! addedToDoTableViewCell
        let object = filtersTask[indexPath.row]
        cell.congifure(detail: object.detail, categoryName: object.category?.name ?? "未カテゴリ", isDone: object.isDone)
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
            calendar.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editGiveTask = filtersTask[indexPath.row]
        index = indexPath.row
        hidesBottomBarWhenPushed = true
        performSegue(withIdentifier: "EditSegue", sender: nil)
        hidesBottomBarWhenPushed = false
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension CalendarToDoViewController: SwipeCardViewControllerDelegate{
    // SwipeCardViewControllerのデリゲートメソッド: バックボタンを押した時に呼ばれる
    func catchDidSwipeCardData(catchTask: Results<Task>) {
        tasks = catchTask
        tableView.reloadData()
    }

}
