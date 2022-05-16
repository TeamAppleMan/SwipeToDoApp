//
//  InputTaskViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import RealmSwift

protocol InputCategoryViewControllerDelegate: AnyObject {
    func addNewDate(detail: String, index: Int)
}

class InputCategoryViewController: UIViewController {

    private var catchTask: String = ""
    private(set) var selectedIndexNumber: Int = 0
    private var categoryList: Results<CategoryList>!
    private var list: List<CategoryList>!

    @IBOutlet private var tableView: UITableView!
    weak var delegate: InputCategoryViewControllerDelegate!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SelectCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectCategoryID")
        tableView.rowHeight = 60
        let realm = try! Realm()
        list = realm.objects(CategoryLists.self).first?.list
    }

    func configure(task: String) {
        catchTask = task
    }

}

extension InputCategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCategoryID", for: indexPath) as! SelectCategoryTableViewCell

        cell.configure(imagePhoto: list[indexPath.row].photo!, name: list[indexPath.row].name)
        print("name",list[indexPath.row].name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexNumber = indexPath.row
        delegate.addNewDate(detail: catchTask, index: selectedIndexNumber)
        dismiss(animated: true, completion: nil)
    }

}

