//
//  ExpenseModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 1.08.2024.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

struct ExpenseModel {
    var id: String?
    var date: Date
    var title: String
    var note: String
    var amount: Double
    var category: String
    
    init(id: String? = nil, date: Date, title: String, note: String, amount: Double, category: String) {
        self.id = id
        self.date = date
        self.title = title
        self.note = note
        self.amount = amount
        self.category = category
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let title = data["title"] as? String,
              let note = data["note"] as? String,
              let amount = data["amount"] as? Double,
              let category = data["category"] as? String else {
            return nil
        }
        self.id = document.documentID
        self.date = date
        self.title = title
        self.note = note
        self.amount = amount
        self.category = category
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "date": date,
            "title": title,
            "note": note,
            "amount": amount,
            "category": category
        ]
    }
}
