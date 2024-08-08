//
//  ExpenseHandling.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 8.08.2024.
//

import Foundation

protocol ExpenseHandling: ObservableObject {
    func fetchRecentExpenses()
    func fetchExpenses(for category: String)
    var expenses: [ExpenseModel] { get set }
    func deleteExpense(id: String)
}
