//
//  Task.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
//class Task: Codable{
//    var date: Date!
//    var detail: String!
//    var category: String!
//    var isRepeatedTodo: Bool!
//    var isDone: Bool!
//    var photos: UIImage!
//    init(date: Date,detail: String,category: String,isRepeatedTodo: Bool,isDone: Bool,photos: UIImage){
//        self.date = date
//        self.detail = detail
//        self.category = category
//        self.isRepeatedTodo = isRepeatedTodo
//        self.isDone = isDone
//        self.photos = photos
//    }
//}
//struct Task: Codable {
//    var detail: String
//    var isDone: Bool
//    var category: String
//    var photos: UIImage
//
//    init(detail: String, isDone: Bool,category: String) {
//        self.detail = detail
//        self.isDone = isDone
//        self.category = category
//        // self.photos = photos
//    }
//}
final class Task {
    var date: Date
    var detail: String
    var category: String
    var isRepeatedTodo: Bool
    var isDone: Bool
    var photos: UIImage?

    init(date: Date,detail: String,category: String,isRepeatedTodo: Bool,isDone: Bool,photos: UIImage?){
        self.date = date
        self.detail = detail
        self.category = category
        self.isRepeatedTodo = isRepeatedTodo
        self.isDone = isDone
        self.photos = photos
    }

}

extension Task: Codable {

    // Decodable
    enum CodingKeys: String, CodingKey {
        case date
        case detail
        case category
        case isRepeatedTodo
        case isDone
        case photos
    }

    convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let date = try values.decode(Date.self, forKey: .date)
        let detail = try values.decode(String.self, forKey: .detail)
        let category = try values.decode(String.self, forKey: .category)
        let isRepeatedTodo = try values.decode(Bool.self, forKey: .isRepeatedTodo)
        let isDone = try values.decode(Bool.self, forKey: .isDone)

        let imageDataBase64String = try values.decode(String.self, forKey: .photos)
        let photos: UIImage?
        if let data = Data(base64Encoded: imageDataBase64String) {
            photos = UIImage(data: data)
        } else {
            photos = nil
        }
        self.init(date: date, detail: detail, category: category, isRepeatedTodo: isRepeatedTodo, isDone: isDone, photos: photos)
        // self.init(id: id, title: title, image: photos)
    }

    // Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(detail, forKey: .detail)
        try container.encode(isRepeatedTodo, forKey: .isRepeatedTodo)
        try container.encode(isDone, forKey: .isDone)
        try container.encode(category, forKey: .category)

        if let image = photos, let imageData = image.pngData() {
            let imageDataBase64String = imageData.base64EncodedString()
            try container.encode(imageDataBase64String, forKey: .photos)
        }
    }

}
