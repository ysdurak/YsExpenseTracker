//
//  CategoryDetailViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation


class CategoryDetailViewModel: ObservableObject {
    @Published var expenses: [ExpenseModel]?
    private var currentCategory: String?
    
    func fetchExpenses(for category: String) {
        self.currentCategory = category
        Services.shared.getExpensesByCategory(category: category) { expenses, error in
            self.expenses = expenses?.sortExpensesDescending()
        }
    }
    
    func deleteExpense(id: String) {
        Services.shared.deleteExpense(id: id) { error in
            if let error = error {
                print("Failed to delete expense: \(error.localizedDescription)")
            } else {
                self.fetchExpenses(for: self.currentCategory ?? "")
            }
        }
    }
    
}

