//
//  CategoryDetailView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation
import SwiftUI

struct CategoryDetailView: View {
    let category: CategoryModel
    @StateObject var viewModel = CategoryDetailViewModel()
    
    var body: some View {
        ZStack{
            VStack {
                Text("Kategori: \(category.title)")
                    .font(.headline)
                
                List {
                    ForEach(viewModel.expenses, id: \.id) { expense in
                        NavigationLink(destination: ExpenseDetailView(expense: expense, viewModel: viewModel, source: .category)
                        ) {
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
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .onAppear {
                viewModel.fetchExpenses(for: category) // Kategoriyi viewModel'e gönder
            }}
    }
}



