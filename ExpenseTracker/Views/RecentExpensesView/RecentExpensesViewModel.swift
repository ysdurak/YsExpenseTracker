//
//  RecentExpensesViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 1.08.2024.
//

import Foundation
import Combine

class RecentExpensesViewModel: ObservableObject {
    @Published var expenses: [ExpenseModel] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchRecentExpenses()
    }

    func fetchRecentExpenses() {
        Services.shared.getAllExpenses { [weak self] (expenses, error) in
            if let expenses = expenses {
                self?.expenses = expenses.sortExpensesDescending()
            } else if let error = error {
                print("Failed to fetch expenses: \(error.localizedDescription)")
            }
        }
    }

    func deleteExpense(id: String) {
        Services.shared.deleteExpense(id: id) { error in
            if let error = error {
                print("Failed to delete expense: \(error.localizedDescription)")
            } else {
                self.fetchRecentExpenses()
            }
        }
    }
}
