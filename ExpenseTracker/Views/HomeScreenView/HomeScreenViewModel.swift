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
    @Published var dailySpent: Double = 0.0
    @Published var dailyLimit: Double = 0
    
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
        
        dispatchGroup.enter()
        fetchDailyLimit {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
     func fetchDailyExpenses() {
        Services.shared.fetchTodayExpenses { totalSpent, error in
            if let totalSpent = totalSpent {
                self.dailySpent = totalSpent
            } else if let error = error {
                print("Error fetching daily expenses: \(error)")
            }
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
    
    func generateDaysInCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let range = calendar.range(of: .day, in: .month, for: today) else {
            return []
        }
        
        let days = range.compactMap { day -> Date? in
            var components = calendar.dateComponents([.year, .month], from: today)
            components.day = day
            return calendar.date(from: components)
        }
        
        return days
    }
    
    func generateDaysInCurrentWeek() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        // Haftanın hangi günü olduğunu bul
        let weekday = calendar.component(.weekday, from: today)
        
        // Haftanın başlangıç günü (Pazartesi)
        let startOfWeek = calendar.date(byAdding: .day, value: -((weekday - calendar.firstWeekday) % 7), to: today)!
        
        // Haftanın günlerini oluştur
        var days: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(date)
            }
        }
        
        return days
    }

    
    // Helper function to match expenses to days
    func generateExpenseData(for days: [Date], from expenses: [ExpenseModel]) -> [(date: Date, amount: Double)] {
        var data: [(date: Date, amount: Double)] = []
        
        for day in days {
            let total = expenses
                .filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.amount }
            data.append((date: day, amount: total))
        }
        
        return data
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
    
    func fetchDailyLimit(completion: @escaping () -> Void) {
        Services.shared.getDailyLimit { [weak self] limit, error in
            if let limit = limit {
                self?.dailyLimit = limit
            } else if let error = error {
                print("Error fetching daily limit: \(error)")
            }
            completion()
        }
    }
    
}



extension Array where Element == (date: Date, amount: Double) {
    func totalAmount() -> Double {
        return self.reduce(0.0) { result, element in
            result + element.amount
        }
    }
}
