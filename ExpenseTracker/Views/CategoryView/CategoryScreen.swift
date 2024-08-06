//
//  CategoryScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation
import SwiftUI
import Charts


struct CategoryScreen: View {
    @StateObject private var viewModel = CategoryViewModel()
    var body: some View {
        NavigationStack{
        ZStack{
            VStack {
                Text("Kategorilere Göre Harcamalar")
                    .customFont(.black, 16)
                    .padding()
                
                if let categoryExpenses = viewModel.categoryExpenses {
                    
                    PieChartView(data: categoryExpenses)
                        .frame(height: 300)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        Color(.white)
                            .frame(height: 10)
                        ForEach(categoryExpenses, id: \.category) { categoryExpense in
                            NavigationLink(
                                destination: CategoryDetailView(category: categoryExpense.category)
                            ) {
                                ExpenseCell(imageName: "car", category: categoryExpense.category, amount: categoryExpense.total.toReadableString())
                                    .padding(.horizontal, 10)
                                    .foregroundColor(.black)
                            }
                            
                        }
                        Color(.white)
                            .frame(height: 50)
                    }
                    
                } else {
                    ProgressView()
                }
                
                
                Spacer()
                
            }
        }
        .onAppear {
            viewModel.fetchMonthlyExpenses()
        }}
    }
}

struct PieChartView: View {
    var data: [(category: String, total: Double)]
    
    var body: some View {
        Chart(data, id: \.category) { item in
            SectorMark(
                angle: .value("Total", item.total),
                innerRadius: .ratio(0.5),
                angularInset: 1
            )
            .foregroundStyle(by: .value("Category", item.category))
        }
        .chartLegend(position: .bottom, alignment: .center, spacing: 30)
    }
}
