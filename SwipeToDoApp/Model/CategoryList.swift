//
//  CategoryList.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import Foundation
import RealmSwift

class CategoryList: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var photo: Data? = nil
}
