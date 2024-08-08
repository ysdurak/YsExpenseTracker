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
    let options = ["Yemek", "Oyun", "Kıyafet", "Market", "Teknoloji", "Fatura", "Eğlence", "Tatil", "Kira", "Abonelikler"]
}
