//
//  ViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import FSCalendar
import MaterialComponents

class CalendarToDoViewController: UIViewController {

    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var taskTextField: MDCOutlinedTextField!
    @IBOutlet var dateLabel: UILabel!

    private var searchTasks: [Task]? = []
    private var taskDatas: [Task]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setCalendar()
        setTextField()
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
    // 余白タッチでキーボード収納
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // セミモーダルへの画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        if let sheet = nav.sheetPresentationController {
            let inputTaskVC = nav.topViewController as! InputCategoryViewController
            //inputTaskVC.task = taskTextField.text ?? "aaa"
            sheet.detents = [.medium()]
            //モーダル出現後も親ビュー操作可能にする
            //sheet.largestUndimmedDetentIdentifier = .medium
            // 角丸の半径を変更する
            sheet.preferredCornerRadius = 20.0
            //　グラバーを表示する（上の灰色のバー）
            sheet.prefersGrabberVisible = true
        }

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
        // Why?: ここでtableView.reloadData()を行なっている理由
        tableView.reloadData()
        let calPosition = Calendar.current
        let comp = calPosition.dateComponents( [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,
                                                Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date)
        taskTextField.placeholder = "\(comp.month!)月\(comp.day!)日のタスクを追加"
        dateLabel.text = "\(comp.year!)年\(comp.month!)月\(comp.day!)日"
    }
}
extension CalendarToDoViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchTasks = []

        // 現在選択されたデータの取得。なぜか１日ずれるため１日ずらす
        guard let selectedDate = calendar.selectedDate, let nowSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return 0
        }

        // 配列の中から選択された同じ日付のデータが存在するかを調べて、あればsearchTasksに追加
        searchTasks = taskDatas?.filter {
            $0.date ==  nowSelectedDate
        }

        return searchTasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedToDoID", for: indexPath) as! addedToDoTableViewCell
        // 後で書く
        cell.detailLabel.text = searchTasks?[indexPath.row].detail
        cell.categoryLabel.text = searchTasks?[indexPath.row].category ?? ""
        return cell
    }
}

