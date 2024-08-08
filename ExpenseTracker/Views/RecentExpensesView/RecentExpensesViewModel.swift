//
//  RecentExpensesViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 1.08.2024.
//

import Foundation
import Combine


class RecentExpensesViewModel: ObservableObject, ExpenseHandling {
    @Published var expenses: [ExpenseModel] = []
    @Published var searchText = ""
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchRecentExpenses()
    }
    
    var filteredExpenses: [ExpenseModel] {
        if searchText.isEmpty {
            return expenses
        } else {
            return expenses.filter { expense in
                expense.note.lowercased().contains(searchText.lowercased()) ||
                expense.category.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func fetchExpenses(for category: String) {
        
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


