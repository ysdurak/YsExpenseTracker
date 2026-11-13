//
//  CategoryScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 6.08.2024.
//

import Foundation
import SwiftUI
import Charts

struct CategoryScreen: View {
    @StateObject private var viewModel = CategoryViewModel()
    @AppStorage("categoryChartPeriod") private var period: SpendingPeriod = .month

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Dönem", selection: $period) {
                    ForEach(SpendingPeriod.allCases) { period in
                        Text(period.title).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                if let categoryExpenses = viewModel.categoryExpenses {
                    if categoryExpenses.isEmpty {
                        ContentUnavailableView(
                            "Harcama yok",
                            systemImage: "chart.pie",
                            description: Text("\(period.label) için kayıtlı harcama bulunamadı.")
                        )
                        .padding(.top, 40)
                    } else {
                        let total = categoryExpenses.reduce(0) { $0 + $1.total }

                        PieChartView(data: categoryExpenses, periodLabel: period.label)
                            .frame(height: 260)
                            .card(padding: 20)

                        VStack(spacing: 0) {
                            ForEach(Array(categoryExpenses.enumerated()), id: \.element.category) { index, item in
                                if index > 0 { Divider().padding(.leading, 48) }
                                NavigationLink(destination: CategoryDetailView(category: item.category)) {
                                    ExpenseCell(category: item.category, amount: item.total, share: item.total / total)
                                        .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .card()
                    }
                } else {
                    ProgressView()
                        .padding(.top, 80)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color.appBackground)
        .navigationTitle("Kategoriler")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.fetchExpenses(for: period) }
        .onChange(of: period) { viewModel.fetchExpenses(for: period) }
    }
}

struct PieChartView: View {
    var data: [(category: CategoryModel, total: Double)]
    var periodLabel: String

    @State private var selectedID: String?

    /// Small categories beyond the top ones are merged so slices stay readable.
    private static let maxSlices = 6
    private static let otherCategory = CategoryModel(title: "Diğer", identifier: "other")

    private struct Slice: Identifiable {
        var category: CategoryModel
        var total: Double
        var color: Color
        var id: String { category.identifier }
    }

    private var slices: [Slice] {
        let visible = data.count > Self.maxSlices ? Array(data.prefix(Self.maxSlices - 1)) : data
        var slices = visible.map { Slice(category: $0.category, total: $0.total, color: categoryColor(identifier: $0.category.identifier)) }
        let remainder = data.dropFirst(visible.count).reduce(0) { $0 + $1.total }
        if remainder > 0 {
            if let index = slices.firstIndex(where: { $0.category.identifier == Self.otherCategory.identifier }) {
                slices[index].total += remainder
            } else {
                slices.append(Slice(category: Self.otherCategory, total: remainder, color: .gray))
            }
        }
        return slices
    }

    private var totalAmount: Double {
        data.reduce(0) { $0 + $1.total }
    }

    /// Slice under `point`, measured clockwise from 12 o'clock like `SectorMark` draws them.
    private func slice(at point: CGPoint, in frame: CGRect) -> Slice? {
        let dx = point.x - frame.midX
        let dy = point.y - frame.midY
        let radius = min(frame.width, frame.height) / 2
        let distance = (dx * dx + dy * dy).squareRoot()
        guard distance >= radius * 0.64, distance <= radius else { return nil }

        var angle = atan2(dx, -dy)
        if angle < 0 { angle += 2 * .pi }
        let target = angle / (2 * .pi) * totalAmount

        var cumulative = 0.0
        for slice in slices {
            cumulative += slice.total
            if target <= cumulative { return slice }
        }
        return slices.last
    }

    var body: some View {
        let slices = slices
        let selected = slices.first { $0.id == selectedID }

        Chart(slices) { slice in
            let isSelected = selected?.id == slice.id
            SectorMark(
                angle: .value("Tutar", slice.total),
                innerRadius: .ratio(0.64),
                outerRadius: .ratio(isSelected || selected == nil ? 1 : 0.92),
                angularInset: 2
            )
            .cornerRadius(5)
            .foregroundStyle(slice.color)
            .opacity(selected == nil || isSelected ? 1 : 0.4)
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    // Tap a slice to highlight it; tap it again (or the middle) to clear.
                    .onTapGesture { location in
                        guard let plotFrame = proxy.plotFrame else { return }
                        let id = slice(at: location, in: geometry[plotFrame])?.id
                        selectedID = id == selectedID ? nil : id
                    }
            }
        }
        .chartBackground { proxy in
            GeometryReader { geometry in
                if let plotFrame = proxy.plotFrame {
                    let frame = geometry[plotFrame]
                    VStack(spacing: 2) {
                        Text(selected?.category.title ?? periodLabel)
                            .customFont(.regular, 13)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Text((selected?.total ?? totalAmount).currency)
                            .customFont(.bold, 22)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        if let selected {
                            Text((selected.total / totalAmount).formatted(.percent.precision(.fractionLength(0)).locale(.turkish)))
                                .customFont(.medium, 13)
                                .foregroundStyle(selected.color)
                        }
                    }
                    .frame(width: frame.width * 0.55)
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selected?.id)
        .animation(.snappy, value: selected?.id)
    }
}
