//
//  UserDefaults.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 7.08.2024.
//

import Foundation


class Defaults {
    static let shared = Defaults()
    private init() {
    }
    
    var userCategories: [CategoryModel] = []
    
    let categories = [
        CategoryModel(title: "Yemek", identifier: "food"),
        CategoryModel(title: "Oyun", identifier: "games"),
        CategoryModel(title: "Kıyafet", identifier: "clothing"),
        CategoryModel(title: "Market", identifier: "groceries"),
        CategoryModel(title: "Teknoloji", identifier: "technology"),
        CategoryModel(title: "Fatura", identifier: "bills"),
        CategoryModel(title: "Eğlence", identifier: "entertainment"),
        CategoryModel(title: "Tatil", identifier: "vacation"),
        CategoryModel(title: "Kira", identifier: "rent"),
        CategoryModel(title: "Abonelikler", identifier: "subscriptions")
    ]
}
