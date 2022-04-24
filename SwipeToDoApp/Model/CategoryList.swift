//
//  CategoryList.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import Foundation
import UIKit
import RealmSwift
class CategoryList: Object{
    @objc dynamic var categoryName: String = ""
    @objc dynamic var image: Data? = nil
}
