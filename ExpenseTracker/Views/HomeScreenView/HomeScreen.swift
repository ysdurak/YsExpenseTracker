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
    @AppStorage("homeChartPeriod") private var period: SpendingPeriod = .month

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Yükleniyor...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            SpendingChartCard(
                                period: $period,
                                buckets: viewModel.buckets(for: period),
                                dailyLimit: viewModel.dailyLimit
                            )

                            HStack(spacing: 12) {
                                ExpenseSummary(
                                    imageName: "arrow.down.left",
                                    imageColor: .income,
                                    title: "Bu ay gelir",
                                    value: viewModel.monthlyIncomeValue
                                )
                                ExpenseSummary(
                                    imageName: "arrow.up.right",
                                    imageColor: .expense,
                                    title: "Bu ay gider",
                                    value: viewModel.monthlyExpenseValue
                                )
                            }

                            NavigationLink(destination: DailyLimitSetView()) {
                                DailyLimitProgressView(spent: viewModel.dailySpent, limit: viewModel.dailyLimit)
                            }
                            .buttonStyle(.plain)

                            topCategories
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .refreshable { viewModel.loadData() }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Özet")
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    private var topCategories: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("En Çok Harcadığım Kategoriler")
                    .customFont(.semiBold, 16)
                Spacer()
                NavigationLink(destination: CategoryScreen()) {
                    Text("Tümü")
                        .customFont(.medium, 14)
                        .foregroundStyle(Color.brand)
                }
            }

            let categories = viewModel.topExpenseCategories
            if categories.isEmpty {
                VStack(spacing: 12) {
                    Text("Bu ay henüz harcama yok")
                        .customFont(.regular, 14)
                        .foregroundStyle(.secondary)
                    Button {
                        appModel.currentTab = .addSomething
                    } label: {
                        Label("Harcama ekle", systemImage: "plus")
                            .font(.customFont(.semiBold, 14))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.brand)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                let total = viewModel.monthlyExpenseValue
                ForEach(Array(categories.enumerated()), id: \.element.category) { index, item in
                    if index > 0 { Divider().padding(.leading, 48) }
                    NavigationLink(destination: CategoryDetailView(category: item.category)) {
                        ExpenseCell(category: item.category, amount: item.total, share: total > 0 ? item.total / total : nil)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .card()
    }
}

// MARK: Chart
struct SpendingChartCard: View {
    @Binding var period: SpendingPeriod
    var buckets: [SpendingBucket]
    var dailyLimit: Double

    @State private var selectedDate: Date?

    private let calendar = Calendar.app

    private var total: Double { buckets.reduce(0) { $0 + $1.amount } }
    private var maxAmount: Double { buckets.map(\.amount).max() ?? 0 }
    private var showsLimit: Bool { period != .year && dailyLimit > 0 }

    private var selectedBucket: SpendingBucket? {
        buckets.first { $0.date == selectedDate }
    }

    private func bucket(at date: Date) -> SpendingBucket? {
        buckets.first { calendar.isDate($0.date, equalTo: date, toGranularity: period.bucketUnit) }
    }

    /// Empty days get a short placeholder bar so the timeline stays readable.
    private var placeholderHeight: Double {
        max(maxAmount, showsLimit ? dailyLimit : 0, 1) * 0.025
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Dönem", selection: $period) {
                ForEach(SpendingPeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 2) {
                Text(selectedBucket.map(selectionLabel) ?? period.label)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondary)
                Text((selectedBucket?.amount ?? total).currency)
                    .customFont(.bold, 30)
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .animation(.snappy, value: selectedBucket?.amount ?? total)

            chart
                .frame(height: 190)
        }
        .card()
        .onChange(of: period) { selectedDate = nil }
    }

    private var chart: some View {
        Chart {
            ForEach(buckets) { bucket in
                let isEmpty = bucket.amount == 0
                BarMark(
                    x: .value("Tarih", bucket.date, unit: period.bucketUnit),
                    y: .value("Tutar", isEmpty ? placeholderHeight : bucket.amount),
                    width: .ratio(0.6)
                )
                .clipShape(RoundedRectangle(cornerRadius: period == .month ? 3 : 6, style: .continuous))
                .foregroundStyle(barStyle(for: bucket, isEmpty: isEmpty))
            }

            if showsLimit {
                RuleMark(y: .value("Limit", dailyLimit))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.orange.opacity(0.8))
                    .annotation(position: .top, alignment: .leading, spacing: 2) {
                        Text("Günlük limit")
                            .customFont(.regular, 10)
                            .foregroundStyle(.orange)
                    }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    // Tap a bar to inspect it, tap it again to go back to the total.
                    // A plain tap keeps the surrounding ScrollView scrollable.
                    .onTapGesture { location in
                        guard let plotFrame = proxy.plotFrame else { return }
                        let x = location.x - geometry[plotFrame].origin.x
                        guard let date: Date = proxy.value(atX: x), let tapped = bucket(at: date)?.date else {
                            selectedDate = nil
                            return
                        }
                        selectedDate = tapped == selectedDate ? nil : tapped
                    }
            }
        }
        .chartXAxis { xAxis }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 3]))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount.formatted(.number.notation(.compactName).locale(.turkish)))
                    }
                }
            }
        }
        .environment(\.calendar, calendar)
        .environment(\.locale, .turkish)
        .sensoryFeedback(.selection, trigger: selectedBucket?.date)
        .animation(.snappy, value: buckets)
    }

    @AxisContentBuilder
    private var xAxis: some AxisContent {
        switch period {
        case .week:
            AxisMarks(values: .stride(by: .day)) { value in
                axisLabel(value, format: .dateTime.weekday(.abbreviated))
            }
        case .month:
            AxisMarks(values: .stride(by: .day, count: 5)) { value in
                axisLabel(value, format: .dateTime.day())
            }
        case .year:
            AxisMarks(values: .stride(by: .month)) { value in
                axisLabel(value, format: .dateTime.month(.narrow))
            }
        }
    }

    /// Charts ignores the environment locale for axis dates, so format them in Turkish explicitly.
    private func axisLabel(_ value: AxisValue, format: Date.FormatStyle) -> AxisValueLabel<Text> {
        AxisValueLabel(centered: true) {
            Text(value.as(Date.self)?.formatted(format.locale(.turkish)) ?? "")
        }
    }

    private func barStyle(for bucket: SpendingBucket, isEmpty: Bool) -> Color {
        if isEmpty { return Color(.systemFill) }
        if let selectedBucket, selectedBucket.date != bucket.date {
            return Color.brand.opacity(0.3)
        }
        return Color.brand
    }

    private func selectionLabel(_ bucket: SpendingBucket) -> String {
        switch period {
        case .year:
            bucket.date.formatted(.dateTime.month(.wide).year().locale(.turkish))
        default:
            bucket.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(.turkish))
        }
    }
}

// MARK: Daily limit
struct DailyLimitProgressView: View {
    var spent: Double
    var limit: Double

    private var progress: Double { limit > 0 ? min(spent / limit, 1) : 0 }
    private var isOverLimit: Bool { limit > 0 && spent > limit }

    private var tint: Color {
        switch progress {
        case ..<0.6: .green
        case ..<0.9: .orange
        default: .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Günlük Harcama Limiti")
                    .customFont(.semiBold, 16)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }

            if limit > 0 {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemFill))
                        Capsule()
                            .fill(tint.gradient)
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: 10)
                .animation(.easeInOut(duration: 0.5), value: progress)

                HStack {
                    (Text(spent.currency).foregroundStyle(.primary) + Text(" harcandı").foregroundStyle(.secondary))
                        .customFont(.regular, 13)
                    Spacer()
                    if isOverLimit {
                        Text("\((spent - limit).currency) aşıldı")
                            .customFont(.medium, 13)
                            .foregroundStyle(.red)
                    } else {
                        (Text((limit - spent).currency).foregroundStyle(Color.brand) + Text(" kaldı").foregroundStyle(.secondary))
                            .customFont(.regular, 13)
                    }
                }
            } else {
                Text("Harcamalarını kontrol altında tutmak için günlük bir limit belirle.")
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }
}

#Preview {
    HomeScreen()
        .environmentObject(AppViewModel())
}
