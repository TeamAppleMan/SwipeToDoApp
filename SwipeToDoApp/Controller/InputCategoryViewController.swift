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
    private(set) var selectedIndexNumber: Int = 0
    private var categoryList: Results<CategoryList>!

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SelectCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectCategoryID")
        tableView.rowHeight = 60
        // relamで保存されたcategoryListの読み込み
        let realm = try! Realm()
        categoryList = realm.objects(CategoryList.self)
        print(categoryList.count)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func configure(task: String) {
        catchTask = task
    }
}

extension InputCategoryViewController: UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCategoryID", for: indexPath) as! SelectCategoryTableViewCell

        cell.configure(imagePhoto: categoryList[indexPath.row].photo!, name: categoryList[indexPath.row].name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexNumber = indexPath.row
    }

}
