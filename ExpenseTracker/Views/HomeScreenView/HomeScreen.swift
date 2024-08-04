//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 25.03.2024.
//

import Foundation
import SwiftUI
import SwiftUICharts

import SwiftUI
import SwiftUICharts

struct HomeScreen: View {
    @StateObject private var viewModel = HomeScreenViewModel()
    @State private var currentTab: String = "Monthly"
    @Environment(\.colorScheme) private var scheme

    var body: some View {
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
                            Text("Yıllık").tag("Year")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading, 20)
                    }
                    
                    Text(" TL")
                        .font(.largeTitle.bold())
                    
                    BarChart(chartData: viewModel.createChartData())
                        .touchOverlay(chartData: viewModel.createChartData(), specifier: "%.0f")
                        .xAxisLabels(chartData: viewModel.createChartData())
                        .yAxisLabels(chartData: viewModel.createChartData())
                        .infoBox(chartData: viewModel.createChartData())
                        .headerBox(chartData: viewModel.createChartData())
                        .legends(chartData: viewModel.createChartData())
                        .id(viewModel.createChartData().id)
                        .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 250, maxHeight: 400, alignment: .center)
                    
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
                        Text("Tümü")
                            .customFont(.semiBold, 15)
                            .underline()
                        
                    }
                    ExpenseCell(imageName: "internaldrive", category: "Teknoloji", amount: "-1800 TL")
                    ExpenseCell(imageName: "server.rack", category: "Abonelikler", amount: "-782 TL")
                    ExpenseCell(imageName: "cart", category: "Market", amount: "-300 TL")
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
