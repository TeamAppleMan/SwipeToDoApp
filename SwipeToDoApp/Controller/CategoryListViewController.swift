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

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        categoryList = realm.objects(CategoryList.self)
        // カテゴリリストが空の状態（初期状態orカテゴリを全部消した時)はカテゴリーリストを初期化する
        if categoryList.isEmpty{
            initCategory(realm: realm)
        }
        tableView.reloadData()
        setTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    // HACK: 少し冗長すぎる気がする
    // 初期状態の設定または、カテゴリリストがないときはデフォルトの設定にする
    private func initCategory(realm: Realm){
        let imageProgramming: Data! = (UIImage(named: "programming"))?.pngData()
        let imageShopping: Data! = (UIImage(named: "shopping"))?.pngData()
        let imageMtg: Data! = (UIImage(named: "mtg"))?.pngData()
        let programming: CategoryList! = CategoryList.init(value: ["name": "プログラミング","photo": imageProgramming!])
        let shopping: CategoryList! = CategoryList.init(value: ["name": "買い物","photo": imageShopping!])
        let mtg: CategoryList! = CategoryList.init(value: ["name": "会議","photo": imageMtg!])
        try! realm.write{
            realm.add(programming)
            realm.add(shopping)
            realm.add(mtg)
        }
    }

    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryID")
        tableView.rowHeight = 80
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCategorySegue"{
            let addCategoryVC = segue.destination as! AddCategoryViewController
            addCategoryVC.delegate = self
        }else if segue.identifier == "SwipeCardSegue"{
            let nav = segue.destination as! UINavigationController
            let swipeCardVC = nav.topViewController as! SwipeCardViewController
            swipeCardVC.delegate = self
            let realm = try! Realm()
            let filtersTask = try! realm.objects(Task.self).filter("category==%@ && isDone==%@",categoryList[selectedIndexNumber].name,false)
            swipeCardVC.catchTask = filtersTask
        }
    }
    func catchDidSwipeCardData(catchTask: Results<Task>) {
        // カレンダー画面のTableViewをリロードする
        guard let calendarToDoVC = tabBarController?.viewControllers?[0] as? CalendarToDoViewController else{
            return
        }
        calendarToDoVC.tableView.reloadData()
    }
    
}

extension CategoryListViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryID", for: indexPath) as! CategoryTableViewCell
        cell.categoryNameLabel.text = categoryList[indexPath.row].name
        // Data型をUIImageにキャストしている
        cell.categoryImageView.image = UIImage(data: categoryList[indexPath.row].photo!)
        // isDoneがfalseのやつとカテゴリ名でフィルタリングをかけて、個数を出す
        let realm = try! Realm()
        let filtersTask = try! realm.objects(Task.self).filter("category==%@ && isDone==%@",categoryList[indexPath.row].name,false)
        cell.categoryTaskCountLabel.text = String(filtersTask.count)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            try! realm.write{
                let category = categoryList[indexPath.row]
                realm.delete(category)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    // セルをタップした時にスワイプ画面に画面遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexNumber = indexPath.row
        performSegue(withIdentifier: "SwipeCardSegue", sender: nil)
    }
}
extension CategoryListViewController: AddCategoryViewControllerDelegate{
    // AddCategoryViewControllerDelegateによるデリゲートメソッド: 新規カテゴリを追加した時に呼ばれる
    func catchAddedCategoryData(catchAddedCategoryList: CategoryList) {
        // Realmを使用してカテゴリリストのアプリ内保存を行う
        let realm = try! Realm()
        try! realm.write{
            realm.add(catchAddedCategoryList)
        }
        // 新しくカテゴリが追加されたので、カテゴリリストの更新を行う
        tableView.reloadData()
    }
}
