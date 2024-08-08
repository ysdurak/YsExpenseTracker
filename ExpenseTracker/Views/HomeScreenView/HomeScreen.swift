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
    @EnvironmentObject var appModel: AppViewModel
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
                                    NavigationLink(
                                        destination: CategoryDetailView(category: topCategories[index].category)
                                    ) {
                                        ExpenseCell(imageName: "car", category: topCategories[index].category.title, amount: topCategories[index].total.toReadableString())
                                            .padding(.horizontal, 10)
                                            .foregroundColor(.black)
                                    }
                                
                                }
                                
                            } else {
                                Text("Harcama bulunamadı")
                                    .customFont(.light, 16)
                                    .padding(.bottom, 10)
                                
                                Button(action: {
                                    // Tab bar'da 3. sekmeye gitme işlemini gerçekleştir
                                    // Örneğin, bu 3. sekmeyi seçmek için bir Binding kullanabilirsin
                                    appModel.currentTab = .addExpense
                                }) {
                                    Text("Harcama Ekle")
                                        .customFont(.bold, 18)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
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
