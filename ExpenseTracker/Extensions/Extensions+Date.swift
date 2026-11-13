//
//  Extensions+Date.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 23.04.2024.
//

import Foundation

extension Date {
    func dayOfMonth() -> String {
        formatted(.dateTime.day(.twoDigits).locale(.turkish))
    }

    func monthAndYear() -> String {
        formatted(.dateTime.month(.abbreviated).year().locale(.turkish))
    }

    func timeOfDay() -> String {
        formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).locale(.turkish))
    }

    /// "Bugün", "Dün", "12 Kasım" or "12 Kasım 2025".
    func sectionTitle(calendar: Calendar = .app) -> String {
        if calendar.isDateInToday(self) { return "Bugün" }
        if calendar.isDateInYesterday(self) { return "Dün" }
        if calendar.isDate(self, equalTo: Date(), toGranularity: .year) {
            return formatted(.dateTime.day().month(.wide).locale(.turkish))
        }
        return formatted(.dateTime.day().month(.wide).year().locale(.turkish))
    }
}
