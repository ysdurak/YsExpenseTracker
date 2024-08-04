//
//  IncomeModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 4.08.2024.
//


import Foundation
import FirebaseFirestore

struct IncomeModel {
    var id: String?
    var date: Date
    var title: String
    var note: String
    var amount: Double
    
    init(id: String? = nil, date: Date, title: String, note: String, amount: Double) {
        self.id = id
        self.date = date
        self.title = title
        self.note = note
        self.amount = amount
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let title = data["title"] as? String,
              let note = data["note"] as? String,
              let amount = data["amount"] as? Double else {
            return nil
        }
        self.id = document.documentID
        self.date = date
        self.title = title
        self.note = note
        self.amount = amount
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "date": date,
            "title": title,
            "note": note,
            "amount": amount
        ]
    }
}
