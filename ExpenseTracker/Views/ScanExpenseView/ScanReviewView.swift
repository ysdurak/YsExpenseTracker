//
//  ScanReviewView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 13.11.2026.
//

import SwiftUI

// Shows what was read from the images; nothing is saved until the user taps "Seçilenleri ekle"
struct ScanReviewView: View {
    @ObservedObject var viewModel: ScanExpenseViewModel
    var onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Bulunan harcamaları kontrol edin. Sadece seçtikleriniz eklenir.")
                            .customFont(.light, 13)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach($viewModel.rows) { $row in
                            ScanReviewRow(row: $row, categories: viewModel.categories)
                        }
                    }
                    .padding(20)
                }
                .dismissKeyboardOnTap()

                VStack(spacing: 8) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .customFont(.regular, 13)
                            .foregroundColor(.red)
                    }
                    Button {
                        Task {
                            if await viewModel.save() {
                                dismiss()
                                onSaved()
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isSaving {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("Seçilenleri ekle (\(viewModel.selectedCount))")
                                .customFont(.semiBold, 16)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedCount == 0 ? Color.gray : Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.selectedCount == 0 || viewModel.isSaving)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .navigationTitle("Bulunan Harcamalar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
            }
        }
    }
}

struct ScanReviewRow: View {
    @Binding var row: ScanExpenseViewModel.Row
    var categories: [CategoryModel]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                row.isSelected.toggle()
            } label: {
                Image(systemName: row.isSelected && row.isComplete ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(row.isComplete ? .green : .gray)
            }
            .disabled(!row.isComplete)

            VStack(alignment: .leading, spacing: 8) {
                TextField("İşyeri", text: $row.merchant)
                    .font(.customFont(.medium, 15))

                HStack {
                    TextField("Tutar", text: $row.amountText)
                        .keyboardType(.decimalPad)
                        .font(.customFont(.semiBold, 15))
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke((row.amount ?? 0) > 0 ? Color.gray.opacity(0.4) : Color.red, lineWidth: 1)
                        )
                        .frame(maxWidth: 120)
                    Text("TL")
                        .customFont(.medium, 14)
                    Spacer()
                    Menu {
                        ForEach(categories, id: \.identifier) { category in
                            Button(category.title) { row.category = category }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: getImage(categoryName: row.category.identifier))
                            Text(row.category.title)
                                .customFont(.regular, 13)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(.black)
                    }
                }

                if let date = row.date {
                    DatePicker("Tarih", selection: Binding(get: { date }, set: { row.date = $0 }), displayedComponents: [.date, .hourAndMinute])
                        .font(.customFont(.regular, 13))
                } else {
                    Button {
                        row.date = Date()
                    } label: {
                        Label("Tarih ekle", systemImage: "calendar.badge.exclamationmark")
                            .font(.customFont(.regular, 13))
                            .foregroundColor(.red)
                    }
                }

                HStack(spacing: 8) {
                    if let foreignAmount = row.foreignAmount {
                        Text(foreignAmount)
                            .customFont(.regular, 12)
                            .foregroundColor(.gray)
                    }
                    if row.isPossibleDuplicate {
                        Text("Muhtemel tekrar")
                            .customFont(.medium, 12)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(row.isSelected && row.isComplete ? Color.green : Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}
