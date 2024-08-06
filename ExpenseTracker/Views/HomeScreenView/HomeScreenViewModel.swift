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
    @Published var topExpenseCategories: [(category: String, total: Double)]?
    
    init() {
        getIncome()
        getExpense()
        fetchMonthlyExpenses()
    }
    


    func fetchWeeklyExpenses(completion: (() -> Void)) {
        Services.shared.getWeeklyExpenses { [weak self] expenses, error in
            if let expenses = expenses {
                DispatchQueue.main.async {
                    self?.weeklyExpenses = expenses
                }
            }
        }
    }
    
    func fetchMonthlyExpenses() {
        Services.shared.getMonthlyExpenses { [weak self] expenses, error in
            if let expenses = expenses {
                DispatchQueue.main.async {
                    self?.monthlyExpenses = expenses
                    self?.topExpenseCategories = self?.top3Categories(expenses: expenses)
                    
                }
            }
        }
    }
    
    func fetchYearlyExpenses() {
        Services.shared.getYearlyExpenses { [weak self] expenses, error in
            if let expenses = expenses {
                DispatchQueue.main.async {
                    self?.yearlyExpenses = expenses
                }
            }
        }
    }
    
    func getIncome() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        Services.shared.getMonthlyIncome(year: currentYear, month: currentMonth) { income, error in
            if let error {
                print("Error")
            } else {
                self.monthlyIncomeValue = income
                print(income)
            }
        }
    }
    
    func getExpense() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        Services.shared.getMonthlyExpense(year: currentYear, month: currentMonth) { expense, error in
            if let error {
                print("Error")
            } else {
                self.monthlyExpenseValue = expense
                print(expense)
            }
        }
    }
    
    func top3Categories(expenses: [ExpenseModel]) -> [(category: String, total: Double)] {
        // kategorilere göre toplam harcama hesaplama
        var categoryTotals: [String: Double] = [:]
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
