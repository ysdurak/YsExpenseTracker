//
//  CategoryModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 8.08.2024.
//

import Foundation
import FirebaseFirestore

struct CategoryModel: Equatable, Hashable, Decodable {
    var title: String
    var identifier: String
    
    init(title: String, identifier: String) {
        self.title = title
        self.identifier = identifier
    }
    
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
              let identifier = data["identifier"] as? String else {
            return nil
        }
        self.title = title
        self.identifier = identifier
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "identifier": identifier
        ]
    }
}
