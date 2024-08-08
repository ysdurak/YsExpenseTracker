//
//  EditExpenseView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 7.08.2024.
//

import Foundation
import SwiftUI

struct EditExpenseView<ViewModel: ExpenseHandling>: View {
    @Binding var expense: ExpenseModel
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel
    let categories = Defaults.shared.categories
    @State var selectedOptionIndex: Int
    let source: EditSource
    var firstCategory: String

    init(expense: Binding<ExpenseModel>, viewModel: ViewModel, source: EditSource) {
        self._expense = expense
        self.viewModel = viewModel
        self.source = source
        _selectedOptionIndex = State(initialValue: categories.firstIndex(of: expense.wrappedValue.category) ?? 0)
        self.firstCategory = expense.wrappedValue.category.identifier
    }
    var body: some View {
        Form {
            Section(header: Text("Kategori")) {
                Picker("Kategori", selection: $selectedOptionIndex) {
                    ForEach(0..<categories.count, id: \.self) { index in
                        Text(categories[index].title)
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedOptionIndex) { newIndex in
                    expense.category = categories[newIndex]
                }
            }
            
            Section(header: Text("Not")) {
                TextField("Not", text: $expense.note)
            }
            
            Section(header: Text("Tutar")) {
                TextField("Tutar", value: $expense.amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }
            
            Section(header: Text("Harcama Tarihi")) {
                DatePicker("Harcama Tarihi", selection: $expense.date, displayedComponents: .date)
            }
            
            Button("Kaydet") {
                Services.shared.updateExpense(expense) { error in
                    if let error = error {
                        print("Error updating expense: \(error.localizedDescription)")
                    } else {
                        switch source {
                        case .recentExpenses:
                            viewModel.fetchRecentExpenses()
                        case .category:
                            viewModel.fetchExpenses(for: firstCategory)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Harcama Düzenle")
    }
}


enum EditSource {
    case recentExpenses
    case category
}
