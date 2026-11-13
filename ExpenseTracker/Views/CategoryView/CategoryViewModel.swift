//
//  CategoryViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categoryExpenses: [(category: CategoryModel, total: Double)]?

    func fetchExpenses(for period: SpendingPeriod) {
        let interval = period.interval()
        Services.shared.getExpensesByDate(startDate: interval.start, endDate: interval.end) { [weak self] expenses, error in
            DispatchQueue.main.async {
                if let expenses {
                    self?.categoryExpenses = expenses.within(interval).categoryTotals()
                } else if let error {
                    print("Error fetching category expenses: \(error)")
                    self?.categoryExpenses = []
                }
            }
        }
    }
}
