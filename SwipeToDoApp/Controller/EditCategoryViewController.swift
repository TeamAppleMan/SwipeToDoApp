//
//  EditCategoryViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/05/08.
//

import UIKit
import RealmSwift

protocol EditCategoryViewControllerDelegate: AnyObject {
    func changeCategory(category: String)
}

class EditCategoryViewController: UIViewController {

    private var categoryList: Results<CategoryList>!
    private var list: List<CategoryList>!

    private(set) var selectCategory: String?
    @IBOutlet private var tableView: UITableView!
    weak var delegate: EditCategoryViewControllerDelegate!
    let realm = try! Realm()

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
        cell.configure(imagePhoto: list[indexPath.row].photo!, name: list[indexPath.row].name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCategory = list[indexPath.row].name
        delegate.changeCategory(category: selectCategory!)
        dismiss(animated: true, completion: nil)
    }

}
