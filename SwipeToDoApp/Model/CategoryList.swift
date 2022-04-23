//
//  CategoryList.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/21.
//

import Foundation
import UIKit
final class CategoryList {
    var categories: String
    var photos: UIImage?
    init(categories: String,photos: UIImage?){
        self.categories = categories
        self.photos = photos
    }
}

extension CategoryList: Codable{
    enum CodingKeys: String, CodingKey {
        case categories
        case photos
    }
    convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let categories = try values.decode(String.self, forKey: .categories)

        let imageDataBase64String = try values.decode(String.self, forKey: .photos)
        let photos: UIImage?
        if let data = Data(base64Encoded: imageDataBase64String) {
            photos = UIImage(data: data)
        } else {
            photos = nil
        }
        self.init(categories: categories, photos: photos)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(categories, forKey: .categories)

        if let image = photos, let imageData = image.pngData() {
            let imageDataBase64String = imageData.base64EncodedString()
            try container.encode(imageDataBase64String, forKey: .photos)
        }
    }
}
