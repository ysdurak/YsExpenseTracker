//
//  ExpenseDetailView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 7.08.2024.
//

import Foundation
import SwiftUI


struct ExpenseDetailView: View {
    @State var expense: ExpenseModel
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Harcama Detayları")
                        .customFont(.bold, 18)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                    }
                    .padding(.trailing)
                    .padding(.top, 10)
                }
                
                Divider()
                    .padding(.vertical, 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    detailRow(iconName: "tag", title: "Kategori", value: expense.category)
                    detailRow(iconName: "note.text", title: "Not", value: expense.note ?? "Bu harcama için not yok")
                    detailRow(iconName: "calendar", title: "Tarih", value: expense.date, formatter: DateFormatter.longDateFormatter)
                    detailRow(iconName: "clock", title: "Saat", value: expense.date, formatter: DateFormatter.timeFormatter)
                    detailRow(iconName: "dollarsign.circle", title: "Tutar", value: "\(String(format: "%.2f", expense.amount)) ₺")
                }
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(15)
                
                Spacer()
            }
        }
        .sheet(isPresented: $isEditing) {
            EditExpenseView(expense: $expense)
        }
    }
    
    private func detailRow(iconName: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(15)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
    
    private func detailRow(iconName: String, title: String, value: Date, formatter: DateFormatter) -> some View {
        detailRow(iconName: iconName, title: title, value: formatter.string(from: value))
    }
}

extension DateFormatter {
    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
