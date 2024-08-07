//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 25.03.2024.
//

import Foundation
import SwiftUI
import Charts

struct HomeScreen: View {
    @StateObject private var viewModel = HomeScreenViewModel()
    @State private var currentTab: String = "Monthly"
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Harcamalar")
                                    .fontWeight(.semibold)
                                Spacer()
                                Picker("", selection: $currentTab) {
                                    Text("Haftalık").tag("Weekly")
                                    Text("Aylık").tag("Monthly")
                                }
                                .pickerStyle(.segmented)
                                .padding(.leading, 20)
                            }
                            
                            Text(viewModel.monthlyExpenseValue.toReadableString() + " TL")
                                .font(.largeTitle.bold())
                            
                            //Bar chart ll come here
                            Chart {
                                ForEach(viewModel.monthlyExpenses) { data in
                                    BarMark(
                                        x: .value("Gün", data.date, unit: .day),
                                        y: .value("Miktar", data.amount)
                                    )
                                }
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill((scheme == .dark ? Color.black : Color.white).shadow(.drop(radius: 2)))
                        }
                        
                        VStack {
                            HStack {
                                Text("Harcama Özetim")
                                    .customFont(.regular, 24)
                                Spacer()
                            }
                            
                            HStack {
                                ExpenseSummary(
                                    imageName: "arrowtriangle.up.circle",
                                    title: "Aylık Gelirlerim",
                                    valueText: viewModel.monthlyIncomeValue.toReadableString() + " ₺",
                                    bgColor: .green.opacity(0.3)
                                )
                                Spacer()
                                    .frame(width: 10)
                                ExpenseSummary(
                                    imageName: "arrowtriangle.down.circle",
                                    title: "Aylık Giderlerim",
                                    valueText: viewModel.monthlyExpenseValue.toReadableString() + " ₺",
                                    bgColor: .red.opacity(0.3)
                                )
                            }
                        }
                        .padding(.top, 10)
                        
                        VStack {
                            HStack {
                                Text("Son Harcamalarım")
                                    .customFont(.regular, 24)
                                Spacer()
                                NavigationLink(destination: CategoryScreen()) {
                                    Text("Tümü")
                                        .customFont(.semiBold, 15)
                                        .underline()
                                }
                            }
                            if let topCategories = viewModel.topExpenseCategories, !topCategories.isEmpty {
                                ForEach(0..<topCategories.count, id: \.self) { index in
                                    ExpenseCell(imageName: "car", category: topCategories[index].category, amount: topCategories[index].total.toReadableString())
                                }
                            } else {
                                Text("Kategori yok")
                                    .customFont(.light, 16)
                                    .padding(.top, 10)
                            }
                        }
                        .padding(.top, 10)
                        
                        Color(.white)
                            .frame(height: 100)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}
