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
        let daysInMonth = viewModel.generateDaysInCurrentMonth()
        let monthlyExpenseData = viewModel.generateExpenseData(for: daysInMonth, from: viewModel.monthlyExpenses)
        let daysInWeek = viewModel.generateDaysInCurrentWeek()
        let weeklyExpenseData = viewModel.generateExpenseData(for: daysInWeek, from: viewModel.weeklyExpenses)
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
                            
                            Text(currentTab == "Weekly" ? weeklyExpenseData.totalAmount().toReadableString() + " TL" : viewModel.monthlyExpenseValue.toReadableString() + " TL")
                                .font(.largeTitle.bold())
                            
                            //Bar chart ll come here
                            Chart {
                                ForEach(currentTab == "Weekly" ? weeklyExpenseData : monthlyExpenseData, id: \.date) { data in
                                    BarMark(
                                        x: .value("Day", data.date, unit: .day),
                                        y: .value("Amount", data.amount)
                                    )
                                    .foregroundStyle(data.amount > 0 ? Color.green : Color.clear) // Show bars only if there's an expense
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) // Show x-axis labels for each day
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
                                    .customFont(.semiBold, 16)
                                Spacer()
                            }
                            
                            HStack {
                                ExpenseSummary(
                                    imageName: "arrow.up.square",
                                    imageColor: Color.green,
                                    title: "Gelirlerim",
                                    valueText: viewModel.monthlyIncomeValue.toReadableString() + " ₺",
                                    bgColor: .clear
                                    
                                )
                                Spacer()
                                    .frame(width: 10)
                                ExpenseSummary(
                                    imageName: "arrow.down.square",
                                    imageColor: Color.red,
                                    title: "Giderlerim",
                                    valueText: viewModel.monthlyExpenseValue.toReadableString() + " ₺",
                                    bgColor: .clear
                                )
                            }
                        }
                        .padding(.top, 10)
                        
                        NavigationLink(destination: DailyLimitSetView()) {
                            DailyLimitProgressView()
                                .environmentObject(viewModel)
                                .foregroundStyle(Color.black)
                        }
                        
                        VStack {
                            HStack {
                                Text("Son Harcamalarım")
                                    .customFont(.semiBold, 16)
                                Spacer()
                                NavigationLink(destination: CategoryScreen()) {
                                    Text("Tümü")
                                        .customFont(.semiBold, 15)
                                        .foregroundStyle(Color.black)
                                        .underline()
                                }
                            }
                            if let topCategories = viewModel.topExpenseCategories, !topCategories.isEmpty {
                                ForEach(0..<topCategories.count, id: \.self) { index in
                                    NavigationLink(
                                        destination: CategoryDetailView(category: topCategories[index].category)
                                    ) {
                                        ExpenseCell(category: topCategories[index].category, amount: topCategories[index].total.toReadableString())
                                            .padding(.horizontal, 10)
                                            .foregroundColor(.black)
                                    }
                                    
                                }
                                
                            } else {
                                Text("Harcama bulunamadı")
                                    .customFont(.extraLight, 16)
                                    .padding(.top, 20)
                                
                                Button(action: {
                                    appModel.currentTab = .addSomething
                                }) {
                                    Image(systemName: "plus.circle")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundStyle(Color.green)
                                }
                            }
                            Color.white
                                .frame(height: 150)
                        }
                        .padding(.top, 10)
                        
                        Spacer()
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


#Preview{
    HomeScreen()
}



struct DailyLimitProgressView: View {
    @EnvironmentObject var viewModel: HomeScreenViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Günlük Harcama Limiti")
                .customFont(.semiBold, 16)
            
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                
                // Progress bar with gradient
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(gradient: Gradient(colors: [.green, .yellow, .red]),
                                         startPoint: .leading,
                                         endPoint: .trailing))
                    .frame(width: progressWidth(), height: 20)
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.dailySpent)
            
            HStack {
                Text("\(viewModel.dailySpent.toReadableString())₺")
                    .foregroundColor(.red) // Harcama kırmızı
                    .customFont(.light, 14) +
                Text(" harcandı")
                    .customFont(.light, 14)
                Spacer()
                Text("\((viewModel.dailyLimit - viewModel.dailySpent).toReadableString())₺")
                    .foregroundColor(.green) // Limit yeşil
                    .customFont(.light, 14) +
                Text(" harcanabilir")
                    .customFont(.light, 14)
            }
            .padding(.top, 5)
        }
        .onAppear {
            viewModel.fetchDailyExpenses()
        }
    }
    
    private func progressWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 40 // Adjust according to your design
        let progress = CGFloat(min(viewModel.dailySpent / viewModel.dailyLimit, 1.0))
        return screenWidth * progress
    }
}

