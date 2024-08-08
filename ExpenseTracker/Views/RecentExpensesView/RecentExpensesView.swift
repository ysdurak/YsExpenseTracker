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
                    SearchBar(text: $viewModel.searchText)
                        .padding(5)
                    
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
                    .navigationTitle("Son Harcamalarım")
                    .navigationBarTitleDisplayMode(.large)
                    .listStyle(PlainListStyle())
                }
            }
        }
        .onAppear {
            viewModel.fetchRecentExpenses()
        }
    }
}




struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Ara..."
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBar
        
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
    }
}
