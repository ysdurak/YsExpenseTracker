//
//  HomeScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import SwiftUICharts
import SwiftUI

class HomeScreenViewModel: ObservableObject {
    @Published var monthlyIncomeValue: Double = 0
    @Published var monthlyExpenseValue: Double = 0
    @Published var weeklyExpenses: [ExpenseModel] = []
    @Published var monthlyExpenses: [ExpenseModel] = []
    @Published var yearlyExpenses: [ExpenseModel] = []
    
    init() {
        getIncome()
        getExpense()
        fetchMonthlyExpenses()
    }
    

     func createChartData() -> BarChartData {
        let groupedExpenses = Dictionary(grouping: monthlyExpenses, by: { Calendar.current.startOfDay(for: $0.date) })
        let sortedDates = groupedExpenses.keys.sorted()
        
        let dataPoints = sortedDates.map { date -> BarChartDataPoint in
            let totalAmount = groupedExpenses[date]?.reduce(0) { $0 + $1.amount } ?? 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d" // Gün olarak formatla
            return BarChartDataPoint(value: totalAmount, xAxisLabel: dateFormatter.string(from: date), description: "\(totalAmount)")
        }
        
        let data = BarDataSet(dataPoints: dataPoints,
                               legendTitle: "Expenses")
        
        let metadata = ChartMetadata(title: "Monthly Expenses", subtitle: "Total Spending per Day")
        
        let gridStyle = GridStyle(numberOfLines: 7,
                                 lineColour: Color(.lightGray).opacity(0.5),
                                 lineWidth: 1,
                                 dash: [8],
                                 dashPhase: 0)
        
        let chartStyle = BarChartStyle(infoBoxPlacement: .infoBox(isStatic: false),
                                        infoBoxBorderColour: Color.primary,
                                        infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
                                        markerType: .vertical(),
                                        xAxisGridStyle: gridStyle,
                                        xAxisLabelPosition: .bottom,
                                        xAxisLabelColour: Color.primary,
                                        xAxisLabelsFrom: .dataPoint(rotation: .degrees(0)),
                                        yAxisGridStyle: gridStyle,
                                        yAxisLabelPosition: .leading,
                                        yAxisLabelColour: Color.primary,
                                        yAxisNumberOfLabels: 7,
                                        baseline: .minimumWithMaximum(of: 100),
                                        topLine: .maximum(of: 1000),
                                        globalAnimation: .easeOut(duration: 1))
        
        return BarChartData(dataSets: data,
                             metadata: metadata,
                             chartStyle: chartStyle)
    }

    func fetchWeeklyExpenses(completion: (() -> Void)) {
        Services.shared.getWeeklyExpenses { [weak self] expenses, error in
            if let expenses = expenses {
                DispatchQueue.main.async {
                    self?.weeklyExpenses = expenses
                }
            }
        }
    }
    
    func fetchMonthlyExpenses() {
        Services.shared.getMonthlyExpenses { [weak self] expenses, error in
            if let expenses = expenses {
                DispatchQueue.main.async {
                    self?.monthlyExpenses = expenses
                }
            }
        }
    }
    
    func fetchYearlyExpenses() {
        Services.shared.getYearlyExpenses { [weak self] expenses, error in
            if let expenses = expenses {
                DispatchQueue.main.async {
                    self?.yearlyExpenses = expenses
                }
            }
        }
    }
    
    func getIncome() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        Services.shared.getMonthlyIncome(year: currentYear, month: currentMonth) { income, error in
            if let error {
                print("Error")
            } else {
                self.monthlyIncomeValue = income
                print(income)
            }
        }
    }
    
    func getExpense() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        Services.shared.getMonthlyExpense(year: currentYear, month: currentMonth) { expense, error in
            if let error {
                print("Error")
            } else {
                self.monthlyExpenseValue = expense
                print(expense)
            }
        }
    }
}
