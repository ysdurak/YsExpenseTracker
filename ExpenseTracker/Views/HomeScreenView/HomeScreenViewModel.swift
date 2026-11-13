//
//  HomeScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import SwiftUI

class HomeScreenViewModel: ObservableObject {
    /// Every expense from the start of the current year (or week, if it began last year) until now.
    @Published var expenses: [ExpenseModel] = []
    @Published var monthlyIncomeValue: Double = 0
    @Published var isLoading: Bool = true
    @Published var dailyLimit: Double = 0

    private let calendar = Calendar.app

    var monthlyExpenseValue: Double {
        expenses.within(SpendingPeriod.month.interval()).total()
    }

    var dailySpent: Double {
        guard let today = calendar.dateInterval(of: .day, for: Date()) else { return 0 }
        return expenses.within(today).total()
    }

    var topExpenseCategories: [(category: CategoryModel, total: Double)] {
        Array(expenses.within(SpendingPeriod.month.interval()).categoryTotals().prefix(3))
    }

    func buckets(for period: SpendingPeriod) -> [SpendingBucket] {
        expenses.buckets(for: period, calendar: calendar)
    }

    func loadData() {
        // Only show the full-screen spinner on first load; later refreshes update in place.
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        fetchExpenses {
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getIncome {
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

    func fetchExpenses(completion: @escaping () -> Void) {
        let start = min(SpendingPeriod.year.interval().start, SpendingPeriod.week.interval().start)
        Services.shared.getExpensesByDate(startDate: start, endDate: SpendingPeriod.year.interval().end) { [weak self] expenses, error in
            DispatchQueue.main.async {
                if let expenses {
                    self?.expenses = expenses
                } else if let error {
                    print("Error fetching expenses: \(error)")
                }
                completion()
            }
        }
    }

    func getIncome(completion: @escaping () -> Void) {
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        Services.shared.getMonthlyIncome(year: currentYear, month: currentMonth) { income, error in
            DispatchQueue.main.async {
                if let error {
                    print("Error: \(error)")
                } else {
                    self.monthlyIncomeValue = income
                }
                completion()
            }
        }
    }

    func fetchDailyLimit(completion: @escaping () -> Void) {
        Services.shared.getDailyLimit { [weak self] limit, error in
            DispatchQueue.main.async {
                if let limit {
                    self?.dailyLimit = limit
                } else if let error {
                    print("Error fetching daily limit: \(error)")
                }
                completion()
            }
        }
    }
}
