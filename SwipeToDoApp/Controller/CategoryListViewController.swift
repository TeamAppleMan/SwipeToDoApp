//
//  CategoryListViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/
//

import UIKit
import RealmSwift

class CategoryListViewController: UIViewController, SwipeCardViewControllerDelegate{

    @IBOutlet var tableView: UITableView!
    var categoryList: Results<CategoryList>!
    private var task: Results<Task>!
    private var selectedIndexNumber: Int = 0

    // realmを定義
    let realm = try! Realm()
    // 並び替え用のリスト
    var list: List<CategoryList>!
    override func viewDidLoad() {
        super.viewDidLoad()
        let categoryList = CategoryList()
        try! realm.write(){
            if list == nil{
                list = realm.objects(ItemList.self).first?.list
            }else{
                list.append(categoryList)
            }
        }
        setTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.tintColor = .black
        tableView.reloadData()
    }

    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryID")
        tableView.rowHeight = 80
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCategorySegue" {
            let addCategoryVC = segue.destination as! AddCategoryViewController
            addCategoryVC.delegate = self
        }

        if segue.identifier == "SwipeCardSegue" {
            let swipeCardVC = segue.destination as! SwipeCardViewController

            let realm = try! Realm()
            let filtersTask = realm.objects(Task.self).filter("category==%@ && isDone==%@",categoryList[selectedIndexNumber].name, false)
            swipeCardVC.catchTask = filtersTask
        }
    }

    func catchDidSwipeCardData(catchTask: Results<Task>) {
        // カレンダー画面のTableViewをリロードする
        guard let calendarToDoVC = tabBarController?.viewControllers?[0] as? CalendarToDoViewController else {
            return
        }
        calendarToDoVC.tableView.reloadData()
    }


    @IBAction func tappedEditButton(_ sender: Any) {
        if(tableView.isEditing == false){
            tableView.isEditing = true
        }else{
            tableView.isEditing = false
        }
    }

}

extension CategoryListViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryID", for: indexPath) as! CategoryTableViewCell
        cell.categoryNameLabel.text = list[indexPath.row].name
        // Data型をUIImageにキャストしている
        cell.categoryImageView.image = UIImage(data: list[indexPath.row].photo!)
        // isDoneがfalseのやつとカテゴリ名でフィルタリングをかけて、個数を出す
        let filtersTask = realm.objects(Task.self).filter("category==%@ && isDone==%@",list[indexPath.row].name,false)
        cell.categoryTaskCountLabel.text = String(filtersTask.count)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write{
                let item = list[indexPath.row]
                realm.delete(item)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write{
            let listItem = list[sourceIndexPath.row]
            list.remove(at: sourceIndexPath.row)
            list.insert(listItem, at: destinationIndexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // セルをタップした時にスワイプ画面に画面遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexNumber = indexPath.row
        hidesBottomBarWhenPushed = true
        performSegue(withIdentifier: "SwipeCardSegue", sender: nil)
        hidesBottomBarWhenPushed = false
    }
}
extension CategoryListViewController: AddCategoryViewControllerDelegate{
    // AddCategoryViewControllerDelegateによるデリゲートメソッド: 新規カテゴリを追加した時に呼ばれる
    func catchAddedCategoryData(catchAddedCategoryList: CategoryList) {
        // Realmを使用してカテゴリリストのアプリ内保存を行う
        try! realm.write{
            list.append(catchAddedCategoryList)
        }
        // 新しくカテゴリが追加されたので、カテゴリリストの更新を行う
        tableView.reloadData()
    }
}
