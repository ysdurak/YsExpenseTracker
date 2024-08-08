//
//  CategoryDetailViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation


class CategoryDetailViewModel: ObservableObject, ExpenseHandling {
    @Published var expenses: [ExpenseModel] = []
    
    private var currentCategory: String?
    
    func fetchExpenses(for category: String) {
        self.currentCategory = category
        Services.shared.getExpensesByCategory(category: category) { expenses, error in
            if let categoryExpenses = expenses {
                self.expenses = categoryExpenses.sortExpensesDescending()
            }
        }
    }
    
    func fetchRecentExpenses() {
        
    }
    
    func deleteExpense(id: String) {
        Services.shared.deleteExpense(id: id) { error in
            if let error = error {
                print("Failed to delete expense: \(error.localizedDescription)")
            } else {
                if let category = self.currentCategory {
                    self.fetchExpenses(for: category)
                }
            }
        }
    }
}
