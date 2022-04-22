//
//  JsonEncoder.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/22.
//

import Foundation
class JsonEncoder{
    class func saveItemsToUserDefaults<T: Codable>(list: [T], key: String) {
        let data = list.map { try! JSONEncoder().encode($0) }
        UserDefaults.standard.set(data as [Any], forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func readItemsFromUserUserDefault<T: Codable>(key: String) -> [T] {
        guard let items = UserDefaults.standard.array(forKey: key) as? [Data] else { return [T]() }
        let decodedItems = items.map { try! JSONDecoder().decode(T.self, from: $0) }
        return decodedItems
    }
}
