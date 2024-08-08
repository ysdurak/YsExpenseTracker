//
//  HomeScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import SwiftUI

class HomeScreenViewModel: ObservableObject {
    @Published var monthlyIncomeValue: Double = 0
    @Published var monthlyExpenseValue: Double = 0
    @Published var weeklyExpenses: [ExpenseModel] = []
    @Published var monthlyExpenses: [ExpenseModel] = []
    @Published var yearlyExpenses: [ExpenseModel] = []
    @Published var topExpenseCategories: [(category: CategoryModel, total: Double)]?
    @Published var isLoading: Bool = true
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchWeeklyExpenses {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchMonthlyExpenses {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchYearlyExpenses {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        getIncome {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        getExpense {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    func fetchWeeklyExpenses(completion: @escaping () -> Void) {
        Services.shared.getWeeklyExpenses { [weak self] expenses, error in
            DispatchQueue.main.async {
                if let expenses = expenses {
                    self?.weeklyExpenses = expenses
                }
                completion()
            }
        }
    }
    
    func fetchMonthlyExpenses(completion: @escaping () -> Void) {
        Services.shared.getMonthlyExpenses { [weak self] expenses, error in
            DispatchQueue.main.async {
                if let expenses = expenses {
                    self?.monthlyExpenses = expenses
                    self?.topExpenseCategories = self?.top3Categories(expenses: expenses)
                }
                completion()
            }
        }
    }
    
    func fetchYearlyExpenses(completion: @escaping () -> Void) {
        Services.shared.getYearlyExpenses { [weak self] expenses, error in
            DispatchQueue.main.async {
                if let expenses = expenses {
                    self?.yearlyExpenses = expenses
                }
                completion()
            }
        }
    }
    
    func getIncome(completion: @escaping () -> Void) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        Services.shared.getMonthlyIncome(year: currentYear, month: currentMonth) { income, error in
            DispatchQueue.main.async {
                if let error {
                    print("Error: \(error)")
                } else {
                    self.monthlyIncomeValue = income
                    print(income)
                }
                completion()
            }
        }
    }
    
    func getExpense(completion: @escaping () -> Void) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        Services.shared.getMonthlyExpense(year: currentYear, month: currentMonth) { expense, error in
            DispatchQueue.main.async {
                if let error {
                    print("Error: \(error)")
                } else {
                    self.monthlyExpenseValue = expense
                    print(expense)
                }
                completion()
            }
        }
    }
    
    func top3Categories(expenses: [ExpenseModel]) -> [(category: CategoryModel, total: Double)] {
        // kategorilere göre toplam harcama hesaplama
        var categoryTotals: [CategoryModel: Double] = [:]
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }

        // en yüksek harcama yapılan ilk 3 kategoriyi sıralama ve dönüştürme
        let top3 = categoryTotals.sorted { $0.value > $1.value }.prefix(3).map { (key, value) in
            (category: key, total: value)
        }
        
        // sonuçları döndürme
        return Array(top3)
    }
}

