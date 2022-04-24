//
//  CategoryListViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/
//

import UIKit
import RealmSwift

class CategoryListViewController: UIViewController{

    @IBOutlet var tableView: UITableView!

    var categoryList: Results<CategoryList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // realmに保存されているCategoryListの内容をcategoryListにいれて更新
        let realm = try! Realm()
        categoryList = realm.objects(CategoryList.self)

        // 初期状態の設定または、カテゴリリストがないときはデフォルトの設定にする
        if categoryList.isEmpty{
            let imageProgramming: Data! = (UIImage(named: "programming"))?.pngData()
            let imageShopping: Data! = (UIImage(named: "shopping"))?.pngData()
            let imageMtg: Data! = (UIImage(named: "mtg"))?.pngData()
            let programming: CategoryList! = CategoryList.init(value: ["categoryName": "プログラミング","image": imageProgramming])
            let shopping: CategoryList! = CategoryList.init(value: ["categoryName": "買い物","image": imageShopping])
            let mtg: CategoryList! = CategoryList.init(value: ["categoryName": "会議","image": imageMtg])
            try! realm.write{
                realm.add(programming)
                realm.add(shopping)
                realm.add(mtg)
            }
        }
        tableView.reloadData()
        setTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
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

    @IBAction func reloadButton(_ sender: Any) {
        tableView.reloadData()
    }
}

extension CategoryListViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryID", for: indexPath) as! CategoryTableViewCell
        cell.categoryNameLabel.text = categoryList[indexPath.row].categoryName
        cell.categoryImageView.image = UIImage(data: categoryList[indexPath.row].image!)
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //
            // categoryList.remove(at: indexPath.row)
            // Realmを使用してカテゴリリストのアプリ内保存を行う
            let realm = try! Realm()
            try! realm.write{
                let category = categoryList[indexPath.row]
                realm.delete(category)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
extension CategoryListViewController: AddCategoryViewControllerDelegate{
    func catchAddedCategoryData(catchAddedCategoryList: CategoryList) {
        // Realmを使用してカテゴリリストのアプリ内保存を行う
        let realm = try! Realm()
        try! realm.write{
            realm.add(catchAddedCategoryList)
        }
        tableView.reloadData()
    }


}

//tableView.reloadData()
