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
        Group {
            if viewModel.expenses.isEmpty {
                ContentUnavailableView(
                    "Harcama yok",
                    systemImage: getImage(categoryName: category.identifier),
                    description: Text("\(category.title) kategorisinde harcama bulunamadı.")
                )
            } else {
                ExpenseList(expenses: viewModel.expenses, viewModel: viewModel, source: .category)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        HStack(spacing: 12) {
                            CategoryIcon(identifier: category.identifier, size: 44)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Toplam")
                                    .customFont(.regular, 13)
                                    .foregroundStyle(.secondary)
                                Text(viewModel.expenses.total().currency)
                                    .customFont(.bold, 22)
                            }
                            Spacer()
                        }
                        .card()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.appBackground)
                    }
            }
        }
        .background(Color.appBackground)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchExpenses(for: category)
        }
    }
}
