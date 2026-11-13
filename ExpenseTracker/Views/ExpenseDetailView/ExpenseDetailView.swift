//
//  ExpenseDetailView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 7.08.2024.
//

import Foundation
import SwiftUI


struct ExpenseDetailView<ViewModel: ExpenseHandling>: View {
    @State var expense: ExpenseModel
    @State private var isEditing = false
    @ObservedObject var viewModel: ViewModel
    let source: EditSource
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(spacing: 8) {
                    CategoryIcon(identifier: expense.category.identifier, size: 56)
                    Text(expense.amount.currency)
                        .customFont(.bold, 34)
                    Text(expense.category.title)
                        .customFont(.medium, 15)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                VStack(alignment: .leading, spacing: 0) {
                    detailRow(iconName: "note.text", title: "Not", value: expense.note.isEmpty ? "Bu harcama için not yok" : expense.note)
                    Divider().padding(.leading, 56)
                    detailRow(iconName: "calendar", title: "Tarih", value: expense.date, formatter: DateFormatter.longDateFormatter)
                    Divider().padding(.leading, 56)
                    detailRow(iconName: "clock", title: "Saat", value: expense.date, formatter: DateFormatter.timeFormatter)
                }
                .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(15)
                
                Spacer()
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Harcama Detayları")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Düzenle") { isEditing.toggle() }
        }
        .sheet(isPresented: $isEditing) {
            EditExpenseView(expense: $expense, viewModel: self.viewModel, source: self.source)
        }
    }
    
    private func detailRow(iconName: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: iconName)
                .foregroundStyle(Color.brand)
                .frame(width: 30, height: 30)
                .background(Color.brand.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondary)
                Text(value)
                    .customFont(.medium, 16)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
    
    private func detailRow(iconName: String, title: String, value: Date, formatter: DateFormatter) -> some View {
        detailRow(iconName: iconName, title: title, value: formatter.string(from: value))
    }
}

extension DateFormatter {
    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .turkish
        formatter.dateStyle = .long
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .turkish
        formatter.timeStyle = .short
        return formatter
    }()
}
