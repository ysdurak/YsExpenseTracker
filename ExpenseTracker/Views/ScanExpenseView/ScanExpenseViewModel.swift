//
//  ScanExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 13.11.2026.
//

import Foundation
import SwiftUI
import ExpenseScanner

@MainActor
class ScanExpenseViewModel: ObservableObject {
    enum Source {
        case receipt
        case bankScreenshot
    }

    struct Row: Identifiable {
        let id = UUID()
        var isSelected: Bool
        var merchant: String
        var amountText: String
        var date: Date?
        var category: CategoryModel
        let suggestedCategory: CategoryModel
        let foreignAmount: String?
        let isPossibleDuplicate: Bool

        // Accepts "1.234,56" (Turkish) as well as "1234.56"
        var amount: Double? {
            let text = amountText.trimmingCharacters(in: .whitespaces)
            if text.contains(",") {
                return Double(text.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "."))
            }
            return Double(text)
        }

        // Rows missing an amount or date can't be saved until the user fills them in
        var isComplete: Bool {
            (amount ?? 0) > 0 && date != nil
        }
    }

    @Published var rows: [Row] = []
    @Published var categories: [CategoryModel] = []
    @Published var isProcessing = false
    @Published var isSaving = false
    @Published var showReview = false
    @Published var showNothingFound = false
    @Published var errorMessage: String?
    private var needsOtherCategory = false

    var selectedCount: Int {
        rows.filter { $0.isSelected && $0.isComplete }.count
    }

    func process(_ images: [UIImage], source: Source, userCategories: [CategoryModel]) async {
        guard !images.isEmpty else { return }
        isProcessing = true
        defer { isProcessing = false }

        categories = userCategories
        needsOtherCategory = !categories.contains { $0.identifier == Defaults.otherCategory.identifier }
        if needsOtherCategory {
            categories.append(Defaults.otherCategory)
        }

        do {
            let drafts = try await readDrafts(from: images, source: source)
            guard !drafts.isEmpty else {
                showNothingFound = true
                return
            }
            let rules = (try? await merchantRules()) ?? [:]
            let existing = (try? await existingExpenses(around: drafts.compactMap(\.date))) ?? []
            rows = drafts.map { makeRow(from: $0, rules: rules, existing: existing) }
            errorMessage = nil
            showReview = true
        } catch {
            errorMessage = error.localizedDescription
            showNothingFound = true
        }
    }

    func save() async -> Bool {
        let selected = rows.filter { $0.isSelected && $0.isComplete }
        guard !selected.isEmpty else { return false }
        isSaving = true
        defer { isSaving = false }

        let expenses = selected.map { row in
            ExpenseModel(
                date: row.date ?? Date(),
                title: row.category.title,
                note: [row.merchant, row.foreignAmount].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · "),
                amount: row.amount ?? 0,
                category: row.category
            )
        }
        var newRules: [String: String] = [:]
        for row in selected where row.category != row.suggestedCategory {
            if let key = MerchantCategorizer.ruleKey(for: row.merchant) {
                newRules[key] = row.category.identifier
            }
        }
        let usesOther = selected.contains { $0.category == Defaults.otherCategory }
        let newCategories = usesOther && needsOtherCategory ? [Defaults.otherCategory] : []

        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Services.shared.addScannedExpenses(expenses, merchantRules: newRules, newCategories: newCategories) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
            if !newCategories.isEmpty {
                needsOtherCategory = false
                Defaults.shared.userCategories.append(contentsOf: newCategories)
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Kaydedilemedi: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Reading images

    private func readDrafts(from images: [UIImage], source: Source) async throws -> [DraftExpense] {
        switch source {
        case .receipt:
            // A long receipt can span several scanned pages; stack them into one tall page
            var lines: [OCRLine] = []
            for (index, image) in images.enumerated() {
                for var line in try await recognize(image) {
                    line.box.y = (line.box.y + Double(index)) / Double(images.count)
                    line.box.height /= Double(images.count)
                    lines.append(line)
                }
            }
            let draft = ReceiptParser().parse(lines)
            return draft.amount == nil && draft.merchant.isEmpty ? [] : [draft]
        case .bankScreenshot:
            var pages: [[DraftExpense]] = []
            for image in images {
                pages.append(BankStatementParser().parse(try await recognize(image)))
            }
            return BankStatementParser.merge(pages)
        }
    }

    private func recognize(_ image: UIImage) async throws -> [OCRLine] {
        guard let cgImage = image.cgImage else { return [] }
        return try await TextRecognizer.recognize(cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
    }

    // MARK: - Review rows

    private func makeRow(from draft: DraftExpense, rules: [String: String], existing: [ExpenseModel]) -> Row {
        let identifier = MerchantCategorizer().categoryIdentifier(for: draft.merchant, userRules: rules)
        let category = categories.first { $0.identifier == identifier } ?? Defaults.otherCategory
        let isDuplicate = existing.contains { expense in
            guard let amount = draft.amount, let date = draft.date else { return false }
            return abs(expense.amount - amount) < 0.005 && Calendar.current.isDate(expense.date, inSameDayAs: date)
        }
        let isComplete = (draft.amount ?? 0) > 0 && draft.date != nil
        return Row(
            isSelected: isComplete && !isDuplicate,
            merchant: draft.merchant,
            amountText: draft.amount.map { String(format: "%.2f", $0).replacingOccurrences(of: ".", with: ",") } ?? "",
            date: draft.date,
            category: category,
            suggestedCategory: category,
            foreignAmount: draft.foreignAmount,
            isPossibleDuplicate: isDuplicate
        )
    }

    private func merchantRules() async throws -> [String: String] {
        try await withCheckedThrowingContinuation { continuation in
            Services.shared.getMerchantRules { rules, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: rules ?? [:])
                }
            }
        }
    }

    private func existingExpenses(around dates: [Date]) async throws -> [ExpenseModel] {
        guard let first = dates.min(), let last = dates.max() else { return [] }
        let start = Calendar.current.startOfDay(for: first)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: last))!
        return try await withCheckedThrowingContinuation { continuation in
            Services.shared.getExpensesByDate(startDate: start, endDate: end) { expenses, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: expenses ?? [])
                }
            }
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
