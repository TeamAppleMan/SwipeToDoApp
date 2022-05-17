//
//  CategoryList.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import Foundation
import RealmSwift

class Category: Object {

    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var image: Data!

    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }

}
