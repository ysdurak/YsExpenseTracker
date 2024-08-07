//
//  RecentExpensesView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 19.04.2024.
//

import Foundation
import SwiftUI
import CoreData

struct RecentExpensesView: View {
    @StateObject private var viewModel = RecentExpensesViewModel()
    @State var expenses: [ExpenseModel] = []
    
    var body: some View {
        ZStack{
            NavigationView {
                List {
                    ForEach(viewModel.expenses, id: \.id) { expense in
                        NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                            RecentExpensesCell(
                                date: expense.date,
                                category: expense.category,
                                note: expense.note,
                                value: expense.amount
                            )
                        }
                        .swipeActions(allowsFullSwipe: true) {
                            Button {
                                viewModel.deleteExpense(id: expense.id ?? "")
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .navigationTitle("Son Harcamalarım")
                .navigationBarTitleDisplayMode(.large)
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            viewModel.fetchRecentExpenses()
        }
    }
    
    private func deleteExpense(_ expense: ExpenseModel) {
        withAnimation {
            // Deletion logic here
        }
    }
}
