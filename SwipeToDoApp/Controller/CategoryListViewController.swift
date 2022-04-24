//
//  CategoryListViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/
//

import UIKit

class CategoryListViewController: UIViewController{

    @IBOutlet var tableView: UITableView!
    // TODO: アプリ内保存したカテゴリ値を代入、保存がなければ初期値とする
    var categoryList: [CategoryList] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        //カテゴリーリストが空（アプリ内保存がない）場合は初期値を設定
        if (categoryList.isEmpty) {
            // UIImageをデータ型に変換
            let imageProgramming: Data! = (UIImage(named: "programming"))?.pngData()
            let imageShopping: Data! = (UIImage(named: "shopping"))?.pngData()
            let imageMtg: Data! = (UIImage(named: "mtg"))?.pngData()
            categoryList = [CategoryList(value: ["categoryName": "プログラミング","image": imageProgramming]),CategoryList(value: ["categoryName": "プログラミング","image": imageShopping]),CategoryList(value: ["categoryName": "プログラミング","image": imageMtg])]
//            categoryList = [CategoryList(categoryName: "プログラミング", image: imageProgramming),CategoryList(categoryName: "買い物", image: imageShopping),CategoryList(categoryName: "会議", image: imageMtg)]
        }
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
            categoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
extension CategoryListViewController: AddCategoryViewControllerDelegate{
    func catchAddedCategoryData(catchAddedCategoryList: CategoryList) {
        categoryList.append(catchAddedCategoryList)
        // TODO: カテゴリリストのアプリ内保存を行う
        print(categoryList.count)
        tableView.reloadData()
    }


}

//tableView.reloadData()
