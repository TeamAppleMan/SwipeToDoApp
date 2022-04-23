//
//  CategoryListViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/
//

import UIKit

class CategoryListViewController: UIViewController{

    @IBOutlet var tableView: UITableView!
    // TODO: カテゴリリストはデフォルトを作る
    var categoryList: [CategoryList] = [CategoryList.init(categories: "運動", photos: UIImage(named: "manran")),CategoryList.init(categories: "プログラミング", photos: UIImage(named: "programming")),CategoryList.init(categories: "買い物", photos: UIImage(named: "shopping")),CategoryList.init(categories: "会議", photos: UIImage(named: "mtg"))]

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCategorySegue"{
            let addCategoryVC = segue.destination as! AddCategoryViewController
            addCategoryVC.delegate = self
        }
    }

    @IBAction func tappedPlusCategoryButton(_ sender: Any) {
        performSegue(withIdentifier: "AddCategorySegue", sender: nil)
    }
}

extension CategoryListViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryID", for: indexPath) as! CategoryTableViewCell
        cell.categoryNameLabel.text = categoryList[indexPath.row].categories
        cell.categoryImageView.image = categoryList[indexPath.row].photos
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // HACK: 多分バグ起きる気がする
            categoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
extension CategoryListViewController: AddCategoryViewControllerDelegate{
    func catchAddedCategoryData(catchAddedCategoryList: CategoryList) {
        categoryList.append(catchAddedCategoryList)
        tableView.reloadData()
        
    }


}

//tableView.reloadData()
