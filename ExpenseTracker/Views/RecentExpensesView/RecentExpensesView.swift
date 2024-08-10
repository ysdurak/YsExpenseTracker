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
        ZStack {
            NavigationView {
                VStack {
                    HStack{
                        Text("Son Harcamalarım")
                            .customFont(.semiBold, 24)
                        Spacer()
                    }
                    .padding(.top, 25)
                    .padding(.horizontal, 25)
                    SearchBar(text: $viewModel.searchText)
                        .padding(5)
                    if viewModel.filteredExpenses.isEmpty{
                        Text("Harcama bulunamadı")
                            .customFont(.extraLight, 16)
                            .padding(.top, 20)
                    }
                    else {
                        List {
                            ForEach(viewModel.filteredExpenses, id: \.id) { expense in
                                NavigationLink(destination: ExpenseDetailView(expense: expense, viewModel: viewModel, source: .recentExpenses)
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
                        .navigationBarTitleDisplayMode(.large)
                        .listStyle(PlainListStyle())
                    }
                    Spacer()

                }
            }
        }
        .onAppear {
            viewModel.fetchRecentExpenses()
        }
    }
}





