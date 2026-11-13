//
//  RecentExpensesView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 19.04.2024.
//

import Foundation
import SwiftUI

struct RecentExpensesView: View {
    @StateObject private var viewModel = RecentExpensesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredExpenses.isEmpty {
                    if viewModel.searchText.isEmpty {
                        ContentUnavailableView(
                            "Harcama bulunamadı",
                            systemImage: "tray",
                            description: Text("Eklediğin harcamalar burada listelenir.")
                        )
                    } else {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    }
                } else {
                    ExpenseList(expenses: viewModel.filteredExpenses, viewModel: viewModel, source: .recentExpenses)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Son Harcamalarım")
            .searchable(text: $viewModel.searchText, prompt: "Ara...")
            .refreshable { viewModel.fetchRecentExpenses() }
        }
        .onAppear {
            viewModel.fetchRecentExpenses()
        }
    }
}

/// Inset grouped list of expenses with one section per day.
struct ExpenseList<ViewModel: ExpenseHandling>: View {
    var expenses: [ExpenseModel]
    @ObservedObject var viewModel: ViewModel
    let source: EditSource

    private var sections: [(day: Date, expenses: [ExpenseModel])] {
        let calendar = Calendar.app
        let grouped = Dictionary(grouping: expenses) { calendar.startOfDay(for: $0.date) }
        return grouped
            .map { (day: $0.key, expenses: $0.value.sortExpensesDescending()) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        List {
            ForEach(sections, id: \.day) { section in
                Section {
                    ForEach(section.expenses, id: \.id) { expense in
                        NavigationLink(destination: ExpenseDetailView(expense: expense, viewModel: viewModel, source: source)) {
                            RecentExpensesCell(
                                date: expense.date,
                                category: expense.category,
                                note: expense.note,
                                value: expense.amount
                            )
                        }
                        .swipeActions(allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteExpense(id: expense.id ?? "")
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text(section.day.sectionTitle())
                        Spacer()
                        Text(section.expenses.total().currency)
                            .monospacedDigit()
                    }
                    .font(.customFont(.medium, 13))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
}
