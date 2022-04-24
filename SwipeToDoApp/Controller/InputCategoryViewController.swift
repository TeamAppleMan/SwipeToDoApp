//
//  InputTaskViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit

class InputCategoryViewController: UIViewController {
    var task: String = ""
    var selectedIndexNumber: Int = 0

    @IBOutlet var tableView: UITableView!
    // TODO: ここは画面2からデータベースで持っていきたい
//    var categoryList: [CategoryList] = [CategoryList.init(categories: "運動", photos: UIImage(named: "manran")),CategoryList.init(categories: "プログラミング", photos: UIImage(named: "programming")),CategoryList.init(categories: "買い物", photos: UIImage(named: "shopping")),CategoryList.init(categories: "会議", photos: UIImage(named: "mtg"))]
    // TODO: とりあえず書く
    var categoryList: [CategoryList] = []
    @IBOutlet var selectedLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        selectedLabel.text = "「\(task)」のカテゴリーを選択してください"
    }
}

extension InputCategoryViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath)
        // cell.textLabel?.text = categoryList[indexPath.row].categories
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexNumber = indexPath.row
    }

    
}
