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
    @State var isChartSmall = false
    @State var showLegend = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Kategorilere Göre Harcamalar")
                    .customFont(.black, 16)
                    .padding()
                
                if let categoryExpenses = viewModel.categoryExpenses {
                    PieChartView(data: categoryExpenses , showLegend: $showLegend)
                        .frame(height: isChartSmall ? 100 : 300)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 10)
                    
                    ScrollView {
                        GeometryReader { geo in
                            Color.clear
                                .frame(height: 10) // Set a fixed height to create a trigger point
                                .onChange(of: geo.frame(in: .global).minY) { newValue in
                                    withAnimation {
                                        print(newValue)
                                        isChartSmall = newValue < 300
                                        showLegend = newValue > 300
                                    }
                                }
                        }
                        .frame(height: 10) // Ensure GeometryReader has a frame
                        
                        ForEach(categoryExpenses, id: \.category) { categoryExpense in
                            NavigationLink(
                                destination: CategoryDetailView(category: categoryExpense.category)
                            ) {
                                ExpenseCell(imageName: "car", category: categoryExpense.category.title, amount: categoryExpense.total.toReadableString())
                                    .padding(.horizontal, 10)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
                
                Spacer()
            }
            .onAppear {
                viewModel.fetchMonthlyExpenses()
            }
        }
    }
}

struct PieChartView: View {
    var data: [(category: CategoryModel, total: Double)]
    @Binding var showLegend: Bool
    
    var totalAmount: Double {
        data.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        Chart(data, id: \.category) { item in
            let percentage = item.total / totalAmount * 100
            
            SectorMark(
                angle: .value("Total", item.total),
                innerRadius: .ratio(0.5),
                angularInset: 1
            )
            .foregroundStyle(by: .value("Category", item.category.title))
            .annotation(position: .overlay, alignment: .center) {
                Text(String(format: "%.1f%%", percentage))
                    .customFont(.regular, 16)
                    .foregroundColor(.white)
            }
        }
        .chartLegend(showLegend ? .visible : .hidden)
        .chartLegend(position: .bottom, alignment: .center, spacing: 30)
    }
}

