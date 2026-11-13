//
//  ExpenseCell.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 19.04.2024.
//

import Foundation
import SwiftUI

struct ExpenseCell: View {
    var category: CategoryModel
    var amount: Double
    var share: Double? = nil

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(identifier: category.identifier)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category.title)
                        .customFont(.medium, 15)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(amount.currency)
                        .customFont(.semiBold, 15)
                        .foregroundStyle(.primary)
                }
                if let share {
                    HStack(spacing: 8) {
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(.systemFill))
                                Capsule()
                                    .fill(categoryColor(identifier: category.identifier))
                                    .frame(width: proxy.size.width * min(max(share, 0), 1))
                            }
                        }
                        .frame(height: 5)
                        Text(share.formatted(.percent.precision(.fractionLength(0)).locale(.turkish)))
                            .customFont(.regular, 12)
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 36, alignment: .trailing)
                    }
                }
            }
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

struct ExpenseSummary: View {
    var imageName: String
    var imageColor: Color
    var title: String
    var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: imageName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(imageColor)
                .frame(width: 32, height: 32)
                .background(imageColor.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondary)
                Text(value.currency)
                    .customFont(.semiBold, 18)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .card()
    }
}

struct RecentExpensesCell: View {
    var date: Date
    var category: CategoryModel
    var note: String
    var value: Double

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(identifier: category.identifier, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.title)
                    .customFont(.medium, 15)
                    .foregroundStyle(.primary)
                Text(note.isEmpty ? date.timeOfDay() : "\(note) · \(date.timeOfDay())")
                    .customFont(.regular, 12)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Text("−" + value.currency)
                .customFont(.semiBold, 15)
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}

func getImage(categoryName: String) -> String {
    switch categoryName {
    case "technology":
        return "laptopcomputer"
    case "food":
        return "fork.knife"
    case "groceries":
        return "cart.fill"
    case "games":
        return "gamecontroller.fill"
    case "entertainment":
        return "wand.and.stars"
    case "subscriptions":
        return "play.rectangle.fill"
    case "vacation":
        return "sun.max.fill"
    case "clothing":
        return "tshirt.fill"
    case "bills":
        return "doc.text.fill"
    case "rent":
        return "house.fill"
    case "other":
        return "ellipsis"
    default:
        return "turkishlirasign"
    }
}

/// Fixed color per category so the chart, icons and list always agree.
func categoryColor(identifier: String) -> Color {
    switch identifier {
    case "technology": return .blue
    case "food": return .orange
    case "groceries": return .green
    case "games": return .purple
    case "entertainment": return .pink
    case "subscriptions": return .indigo
    case "vacation": return .yellow
    case "clothing": return .mint
    case "bills": return .red
    case "rent": return .brown
    case "other": return .gray
    default:
        // Custom categories (e.g. from scanning) get a stable color from their identifier.
        let palette: [Color] = [.teal, .cyan, .indigo, .orange, .purple, .mint, .pink, .blue]
        let hash = identifier.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return palette[abs(hash) % palette.count]
    }
}
