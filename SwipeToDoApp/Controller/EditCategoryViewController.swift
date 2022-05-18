//
//  EditCategoryViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/05/08.
//

import UIKit
import RealmSwift

protocol EditCategoryViewControllerDelegate: AnyObject {
    func changeCategory(category: Category?)
}

class EditCategoryViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private let realm = try! Realm()
    private var categoryList: Results<Category>!
    private var list: List<Category>!
    private(set) var selectCategory: Category?
    weak var delegate: EditCategoryViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SelectCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectCategoryID")
        tableView.rowHeight = 60
        let realm = try! Realm()
        list = realm.objects(CategoryLists.self).first?.list
    }

    @IBAction func didTapExitButton(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension EditCategoryViewController: UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCategoryID", for: indexPath) as! SelectCategoryTableViewCell
        cell.configure(category: list[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCategory = list[indexPath.row]
        delegate.changeCategory(category: selectCategory)
        dismiss(animated: true, completion: nil)
    }

}
