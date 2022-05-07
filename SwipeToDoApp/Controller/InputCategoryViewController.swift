//
//  InputTaskViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import RealmSwift

class InputCategoryViewController: UIViewController {

    private var catchTask: String = ""
    private var selectedIndexNumber: Int = 0
    private var categoryList: Results<CategoryList>!

    @IBOutlet private var tableView: UITableView!
    //@IBOutlet private var selectedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SelectCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectCategoryID")
        tableView.rowHeight = 80
        // relamで保存されたcategoryListの読み込み
        let realm = try! Realm()
        categoryList = realm.objects(CategoryList.self)
        tableView.delegate = self
        tableView.dataSource = self
//        selectedLabel.text = """
//            のカテゴリーを選択してください。
//            """
    }

    func configure(task: String, index: Int) {
        catchTask = task
        selectedIndexNumber = index
    }
}

extension InputCategoryViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath)
        cell.textLabel?.text = categoryList[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexNumber = indexPath.row
    }
}

// Labelの一部分だけ太くする
extension UILabel {
    func addUinit(unit: String, size: CGFloat) {
        guard let label = self.text else {
            return
        }
        // 単位との間隔
        let mainString = NSMutableAttributedString(string: label + " ")
        let unitString = NSMutableAttributedString(
            string: unit,
            attributes: [.font: UIFont.systemFont(ofSize: size)])
        let attributedString = NSMutableAttributedString()
        attributedString.append(mainString)
        attributedString.append(unitString)

        self.attributedText = attributedString
    }
}
