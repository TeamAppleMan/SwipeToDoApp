//
//  Task.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import RealmSwift

class Task: Object {
    @objc dynamic var date: Date = Date()
    @objc dynamic var detail: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var isRepeatedTodo: Bool = false
    @objc dynamic var isDone: Bool = false
    @objc dynamic var photo: Data? = nil
}
