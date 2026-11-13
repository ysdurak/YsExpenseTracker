//
//  Theme.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 30.04.2024.
//

import Foundation
import SwiftUI

// MARK: Colors
extension Color {
    static let brand = Color.green
    static let income = Color.green
    static let expense = Color.red
    static let appBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let fieldBackground = Color(.tertiarySystemFill)
    static let tabBarBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .secondarySystemBackground : .black
    })
}

// MARK: Card
struct CardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardModifier(padding: padding))
    }

    /// Rounded text field look shared by the add / login / limit forms.
    func fieldStyle() -> some View {
        self
            .padding(14)
            .background(Color.fieldBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: Buttons
struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .brand

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.customFont(.semiBold, 16))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// MARK: Category icon
struct CategoryIcon: View {
    var identifier: String
    var size: CGFloat = 36

    var body: some View {
        let color = categoryColor(identifier: identifier)
        Image(systemName: getImage(categoryName: identifier))
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
    }
}

// MARK: Locale / Calendar
extension Locale {
    static let turkish = Locale(identifier: "tr_TR")
}

extension Calendar {
    /// Gregorian calendar with weeks starting on Monday, as used in Turkey.
    static let app: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .turkish
        calendar.firstWeekday = 2
        return calendar
    }()
}

// MARK: Currency
extension Double {
    /// "1.234,5 ₺"
    var currency: String {
        formatted(.number.locale(.turkish).precision(.fractionLength(0...2))) + " ₺"
    }
}

extension String {
    /// Parses user input that may use a Turkish decimal comma ("12,50").
    var amountValue: Double? {
        Double(trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "."))
    }
}

// MARK: Periods
enum SpendingPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week: "Hafta"
        case .month: "Ay"
        case .year: "Yıl"
        }
    }

    var label: String {
        switch self {
        case .week: "Bu hafta"
        case .month: "Bu ay"
        case .year: "Bu yıl"
        }
    }

    /// Chart bucket size for this period.
    var bucketUnit: Calendar.Component {
        self == .year ? .month : .day
    }

    /// Calendar-aligned interval containing `date` (Mon–Sun, 1st–end of month, Jan–Dec).
    func interval(containing date: Date = Date(), calendar: Calendar = .app) -> DateInterval {
        let component: Calendar.Component = switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
        return calendar.dateInterval(of: component, for: date) ?? DateInterval(start: date, duration: 0)
    }
}

struct SpendingBucket: Identifiable, Equatable {
    var date: Date
    var amount: Double
    var id: Date { date }
}

extension [ExpenseModel] {
    func total() -> Double {
        reduce(0) { $0 + $1.amount }
    }

    func within(_ interval: DateInterval) -> [ExpenseModel] {
        filter { $0.date >= interval.start && $0.date < interval.end }
    }

    /// One bucket per day (or month for `.year`) of the period, including empty ones.
    func buckets(for period: SpendingPeriod, calendar: Calendar = .app) -> [SpendingBucket] {
        let interval = period.interval(calendar: calendar)
        var totals: [Date: Double] = [:]
        for expense in within(interval) {
            if let start = calendar.dateInterval(of: period.bucketUnit, for: expense.date)?.start {
                totals[start, default: 0] += expense.amount
            }
        }

        var buckets: [SpendingBucket] = []
        var cursor = interval.start
        while cursor < interval.end {
            buckets.append(SpendingBucket(date: cursor, amount: totals[cursor] ?? 0))
            guard let next = calendar.date(byAdding: period.bucketUnit, value: 1, to: cursor) else { break }
            cursor = next
        }
        return buckets
    }

    /// Totals per category, highest first.
    func categoryTotals() -> [(category: CategoryModel, total: Double)] {
        var totals: [CategoryModel: Double] = [:]
        for expense in self {
            totals[expense.category, default: 0] += expense.amount
        }
        return totals.sorted { $0.value > $1.value }.map { (category: $0.key, total: $0.value) }
    }
}

// MARK: Toast
struct SuccessToast: View {
    var title: String
    var message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.brand)
                .symbolEffect(.bounce, value: title)
            Text(title)
                .customFont(.semiBold, 20)
            Text(message)
                .customFont(.regular, 15)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(width: 260)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
