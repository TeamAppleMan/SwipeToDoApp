//
//  Task.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import RealmSwift

class Task: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var detail: String = ""
    @objc dynamic var category: Category? = nil
    @objc dynamic var isRepeatedTodo: Bool = false
    @objc dynamic var isDone: Bool = false

    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }

}
