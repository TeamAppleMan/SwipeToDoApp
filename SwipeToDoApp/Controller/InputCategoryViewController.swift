//
//  InputTaskViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import RealmSwift

class InputCategoryViewController: UIViewController {
    // CandarToDoViewControllerから受け取ったタスク名
    var catchTask: String = ""

    // HACK: カプセル化するか怪しかったので一旦なしで。
    var selectedIndexNumber: Int = 0

    @IBOutlet private var tableView: UITableView!
    private var categoryList: Results<CategoryList>!
    @IBOutlet private var selectedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // relamで保存されたcategoryListの読み込み
        let realm = try! Realm()
        categoryList = realm.objects(CategoryList.self)
        tableView.delegate = self
        tableView.dataSource = self
        selectedLabel.text = "「\(catchTask)」のカテゴリーを選択してください。"
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
