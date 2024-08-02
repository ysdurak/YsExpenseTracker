//
//  SampleAnalyticsManager.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 30.04.2024.
//

import Foundation
import CoreData
import SwiftUI


struct AnimatedGraphData: Identifiable {
    var id = UUID().uuidString
    var date: Date
    var value: Double
    var animate: Bool = false
    var sample_analytics: [AnimatedGraphData] = []

}

struct AnimatedGraphDataManager {
    static func generateSampleAnalytics(from expense: FetchedResults<Expense>, timeRange: TimeRange) -> [AnimatedGraphData] {
        var sampleAnalytics: [AnimatedGraphData] = []
        
        let currentDate = Date()
        let calendar = Calendar.current
        let startDate: Date
        
        switch timeRange {
        case .weekly:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
        case .monthly:
            startDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
        
        let filteredExpense = expense.filter { $0.date ?? Date() >= startDate }
        
        for expense in filteredExpense {
            let date = expense.date ?? Date()
            let value = expense.value
            let animatedGraphData = AnimatedGraphData(date: date, value: value)
            sampleAnalytics.append(animatedGraphData)
        }
        
        return sampleAnalytics
    }
    
    // Other methods remain unchanged
}

enum TimeRange {
    case weekly
    case monthly
}




extension Date {
    // MARK: To Update Date For Particular Day
    func updateDay(value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySetting: .day, value: value, of: self) ?? Date()
    }
}

extension Double{
    var stringFormat: String{
        if self >= 10000 && self < 999999{
            return String(format: "%.1fK",locale: Locale.current, self / 1000).replacingOccurrences(of: ".0", with: "")
        }
        if self > 999999{
            return String(format: "%.1fM",locale: Locale.current, self / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        
        return String(format: "%.0f",locale: Locale.current, self)
    }
}
