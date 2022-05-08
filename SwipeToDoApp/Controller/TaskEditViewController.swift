//
//  TaskEditViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/05/08.
//

import UIKit
import RealmSwift

class TaskEditViewController: UIViewController, EditCategoryViewControllerDelegate{

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var taskTextField: UITextField!
    @IBOutlet private weak var categoryButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    private var getFiltersTask: Results<Task>!
    private var selectCategory: String!
    private var indexNumber: Int!
    private var catchTask: Task!

    override func viewDidLoad() {
        super.viewDidLoad()
        selectCategory = catchTask.category.description
        categoryButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        categoryButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        categoryButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        dateLabel.text = "\(catchTask.date.year)年\(catchTask.date.month)月\(catchTask.date.day)日"
        deleteButton.layer.borderColor = UIColor.systemGray5.cgColor
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.cornerRadius = 8.0

        categoryButton.layer.borderColor = UIColor.systemGray5.cgColor
        categoryButton.layer.borderWidth = 1.0
        categoryButton.layer.cornerRadius = 8.0
        categoryButton.setTitle(" \(selectCategory!) ", for: .normal)
        categoryButton.titleLabel?.adjustsFontSizeToFitWidth = true

        taskTextField.text = catchTask.detail

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavVCSegue" {
            let nav = segue.destination as! UINavigationController
            guard let nextVC = nav.topViewController as? EditCategoryViewController else { return }
            guard let sheet = nav.sheetPresentationController  else { return }
            nextVC.delegate = self

            sheet.detents = [.medium()]
            //モーダル出現後も親ビュー操作不可能にする
            sheet.largestUndimmedDetentIdentifier = .large
            // 角丸の半径
            sheet.preferredCornerRadius = 20.0
            // 上の灰色のバー
            sheet.prefersGrabberVisible = true
        }
    }

    func changeCategory(category: String) {
        selectCategory = category
        categoryButton.setTitle(" \(selectCategory!) ", for: .normal)
    }

    func configure(task: Task, tasks: Results<Task>, index: Int) {
        catchTask = task
        getFiltersTask = tasks
        indexNumber = index
    }

    @IBAction func didTapCategoryButton(_ sender: Any) {
        performSegue(withIdentifier: "NavVCSegue", sender: nil)
    }

    @IBAction func didTapDeleteButton(_ sender: Any) {
        deleteAleart()
    }

    @IBAction private func didTapSaveButton(_ sender: Any) {
        saveAleart()
    }

    func deleteAleart() {
        let alert = UIAlertController(title: "注意", message: "データを完全に削除してもよろしいですか？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
            let realm = try! Realm()
            try! realm.write{
                realm.delete(self.catchTask)
            }
            dismiss(animated: true)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (acrion) in
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    func saveAleart() {
        let alert = UIAlertController(title: "保存", message: "データを上書きしてもよろしいですか？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
            let realm = try! Realm()
            let target = getFiltersTask[indexNumber]
            guard let text = taskTextField.text else {
                print("値から")
                return
            }

            do {
                try realm.write {
                    target.detail = text
                    target.category = selectCategory
                }
            } catch {
                print("画面１のタスク編集画面でRealmエラー")
            }

            dismiss(animated: true)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (acrion) in
        }

        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
