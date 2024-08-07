//
//  EditExpenseView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 7.08.2024.
//

import Foundation
import SwiftUI

struct EditExpenseView: View {
    @Binding var expense: ExpenseModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Kategori")) {
                TextField("Kategori", text: $expense.category)
            }
            
            Section(header: Text("Not")) {
                TextField("Not", text: $expense.note)
            }
            
            Section(header: Text("Tutar")) {
                TextField("Tutar", value: $expense.amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }
            
            Button("Kaydet") {
                Services.shared.updateExpense(expense) { error in
                    if let error = error {
                        print("Error updating expense: \(error.localizedDescription)")
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Harcama Düzenle")
    }
}
