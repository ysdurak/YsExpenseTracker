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
        let expenseData = viewModel.generateExpenseData(for: daysInMonth, from: viewModel.monthlyExpenses)
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
                                ForEach(expenseData, id: \.date) { data in
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
                        
                        Text("Günlük limitim")
                            .customFont(.semiBold, 16)
                        
                        DailyLimitProgressView()
                            .environmentObject(viewModel)
                        
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
                                        ExpenseCell(imageName: "car", category: topCategories[index].category.title, amount: topCategories[index].total.toReadableString())
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
        VStack {
            Text("Günlük Harcama Limiti")
                .font(.headline)
                .padding(.bottom, 10)
            
            ZStack {
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(viewModel.dailySpent / viewModel.dailyLimit, 1.0)))
                    .stroke(AngularGradient(gradient: Gradient(colors: [.green, .yellow, .red]),
                                            center: .center),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(Angle(degrees: 270.0))
                    .frame(width: 150, height: 150)
                
                VStack {
                    Text("\(Int(viewModel.dailySpent)) / \(Int(viewModel.dailyLimit))")
                        .font(.title)
                        .bold()
                    Text("₺ harcandı")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchDailyExpenses()
        }
    }
}
