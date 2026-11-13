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
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return expenses }
        // Case- and diacritic-insensitive, so "gida" matches "Gıda".
        return expenses.filter { expense in
            [expense.note, expense.title, expense.category.title].contains {
                $0.range(of: query, options: [.caseInsensitive, .diacriticInsensitive], locale: .turkish) != nil
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


