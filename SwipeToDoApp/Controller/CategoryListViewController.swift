//
//  CategoryListViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/22.
//

import UIKit

class CategoryListViewController: UIViewController{

    @IBOutlet var tableView: UITableView!
    // TODO: カテゴリリストはデフォルトを作る
    var categoryList = CategoryList()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }

    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryID")
        tableView.rowHeight = 100
    }

    @IBAction func tappedPlusCategoryButton(_ sender: Any) {
        performSegue(withIdentifier: "AddCategorySegue", sender: nil)
    }
}

extension CategoryListViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryID", for: indexPath) as! CategoryTableViewCell
        cell.categoryNameLabel.text = categoryList.categories[indexPath.row]
        cell.categoryImageView.image = categoryList.photos[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // HACK: 多分バグ起きる気がする
            categoryList.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
extension CategoryListViewController: AddCategoryViewControllerDelegate{
    func catchAddedCategoryData(categoryData: CategoryData) {
        categoryList.append(categoryData)
        print(categoryTodoArray)
        tableView.reloadData()
    }
}
