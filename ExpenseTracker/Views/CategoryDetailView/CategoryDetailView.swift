//
//  CategoryDetailView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation
import SwiftUI

struct CategoryDetailView: View {
    let category: String
    @StateObject private var viewModel = CategoryDetailViewModel() // Bu viewModel ilgili kategoriye ait harcamaları getirecek

    var body: some View {
        ZStack{
        VStack {
            Text("Kategori: \(category)")
                .font(.headline)
            
            List{
                if let expenses = viewModel.expenses {
                    ForEach(expenses, id: \.id) { expense in
                        RecentExpensesCell(
                            date: expense.date ,
                            category: expense.category ,
                            note: expense.note,
                            value: expense.amount
                        )
                        .padding()
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
            }
            .listStyle(PlainListStyle())
            
            Spacer()
        }
        .onAppear {
            viewModel.fetchExpenses(for: category) // Kategoriyi viewModel'e gönder
        }}
    }
}


#Preview {
    CategoryDetailView(category: "Teknoloji")
}
