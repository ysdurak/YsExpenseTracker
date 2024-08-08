//
//  CategoryViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation



class CategoryViewModel: ObservableObject {
    @Published var categoryExpenses: [(category: CategoryModel, total: Double)]?
    
    init(){
        
    }
    
    func sumUpExpenseCategories(expenses: [ExpenseModel]) -> [(category: CategoryModel, total: Double)] {
        
        var categoryTotals: [CategoryModel: Double] = [:]
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }

        let allCategories = categoryTotals.sorted { $0.value > $1.value }.map { (key, value) in
            (category: key, total: value)
        }
        
        return allCategories
    }
    
    func fetchMonthlyExpenses() {
        Services.shared.getMonthlyExpenses { [weak self] expenses, error in
            if let expenses = expenses {
                DispatchQueue.main.async {
                    self?.categoryExpenses = self?.sumUpExpenseCategories(expenses: expenses)
                    
                }
            }
        }
    }
    
}
