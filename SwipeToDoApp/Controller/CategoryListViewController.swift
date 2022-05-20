//
//  CategoryListViewController.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/
//

import UIKit
import RealmSwift

class CategoryListViewController: UIViewController, SwipeCardViewControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var editButton: UIBarButtonItem!
    var categoryList: Results<Category>!
    private var task: Results<Task>!
    private var selectedIndexNumber: Int = 0
    let realm = try! Realm()
    var list: List<Category>!
    var category: Category? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        list = realm.objects(CategoryLists.self).first?.list
        setTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        editButton.title = "編集"
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
            swipeCardVC.configureFromCategoryVC(swipeCategory: category)
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
        if tableView.isEditing == true {
            tableView.isEditing.toggle()
            editButton.title = "編集"
        } else {
            tableView.isEditing.toggle()
            editButton.title = "完了"
        }
    }

}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "カテゴリ一覧"
        }
        return "未分類"
    }

    // Section間の隙間をコードで修正
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else {
            return 30
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return list.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryID", for: indexPath) as! CategoryTableViewCell

        if indexPath.section == 0 {
            let filtersTask = realm.objects(Task.self).filter("category==%@ && isDone==%@", list[indexPath.row], false)
            cell.categoryNameLabel.text = list[indexPath.row].name
            // Data型をUIImageにキャスト
            if let image = list[indexPath.row].image {
                cell.categoryImageView?.image = UIImage(data: image)
            }
            // isDoneがfalseのやつとカテゴリ名でフィルタリングをかけて、個数を出す
            cell.categoryTaskCountLabel.text = String(filtersTask.count)
            return cell
        } else {
        // 最終行に未カテゴリセルを追加させる
            let filterNillTask = realm.objects(Task.self).filter("category==nil && isDone==%@", false)
            cell.categoryImageView?.image = UIImage(named: "ハテナ")!
            cell.categoryNameLabel.text = "未カテゴリ"
            cell.categoryTaskCountLabel.text = String(filterNillTask.count)
            return cell
        }

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if editingStyle == .delete {
                try! realm.write {
                    let item = list[indexPath.row]
                    realm.delete(item)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            // 未カテゴリに表示されている数を増やす
            tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)

        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let listItem = list[sourceIndexPath.row]
            list.remove(at: sourceIndexPath.row)
            list.insert(listItem, at: destinationIndexPath.row)
        }

    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }

    // 未カテゴリは並び替えさせない
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
                return proposedDestinationIndexPath
            }
        return sourceIndexPath
    }

    // セルをタップした時にスワイプ画面に画面遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexNumber = indexPath.row
        if indexPath.section == 0 {
            category = list[indexPath.row]
        } else {
            category = nil
        }
        hidesBottomBarWhenPushed = true
        performSegue(withIdentifier: "SwipeCardSegue", sender: nil)
        hidesBottomBarWhenPushed = false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 0 {
            return .delete
            }
            return .none
    }


}

extension CategoryListViewController: AddCategoryViewControllerDelegate{
    // AddCategoryViewControllerDelegateによるデリゲートメソッド: 新規カテゴリを追加した時に呼ばれる
    func catchAddedCategoryData(catchAddedCategoryList: Category) {
        // Realmを使用してカテゴリリストのアプリ内保存を行う
        try! realm.write{
            list.append(catchAddedCategoryList)
        }
        // 新しくカテゴリが追加されたので、カテゴリリストの更新を行う
        tableView.reloadData()
    }

}
