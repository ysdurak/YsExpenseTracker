import Foundation

/// Reads the total, date and store name from a photo of a Turkish printed receipt.
public struct ReceiptParser {
    public var referenceDate: Date
    public var calendar: Calendar

    public init(referenceDate: Date = Date(), calendar: Calendar = .current) {
        self.referenceDate = referenceDate
        self.calendar = calendar
    }

    public func parse(_ lines: [OCRLine]) -> DraftExpense {
        let rows = Self.rows(from: lines)
        return DraftExpense(amount: total(in: rows), date: date(in: rows), merchant: merchant(in: rows))
    }

    /// Joins lines printed at the same height, e.g. "TOPLAM" on the left and "*49,50" on the right.
    private static func rows(from lines: [OCRLine]) -> [String] {
        var rows: [[OCRLine]] = []
        for line in lines.sorted(by: { $0.box.minY < $1.box.minY }) {
            if let index = rows.firstIndex(where: { row in row.contains { abs($0.box.midY - line.box.midY) < min($0.box.height, line.box.height) / 2 } }) {
                rows[index].append(line)
            } else {
                rows.append([line])
            }
        }
        return rows.map { $0.sorted { $0.box.minX < $1.box.minX }.map(\.text).joined(separator: " ") }
    }

    private func total(in rows: [String]) -> Double? {
        let totalRows = rows.filter { row in
            let folded = TurkishText.fold(row)
            return folded.contains("TOPLAM") && !["ARA TOPLAM", "ARATOPLAM", "KDV", "INDIRIM"].contains { folded.contains($0) }
        }
        let preferred = totalRows.last { TurkishText.fold($0).contains("GENEL") } ?? totalRows.last
        if let preferred, let amount = TurkishAmount.receiptAmounts(in: preferred).last {
            return amount
        }
        // No readable TOPLAM line: the largest price is the best guess, skipping cash handed over and change.
        return rows
            .filter { row in !["NAKIT", "PARA USTU", "KDV"].contains { TurkishText.fold(row).contains($0) } }
            .flatMap { TurkishAmount.receiptAmounts(in: $0) }
            .max()
    }

    private func date(in rows: [String]) -> Date? {
        let dateRow = rows.first { TurkishText.fold($0).contains("TARIH") && TurkishDate.day(in: $0) != nil }
            ?? rows.first { TurkishDate.day(in: $0) != nil }
        guard let dateRow, let day = TurkishDate.day(in: dateRow) else { return referenceDate }
        let timeRow = rows.first { TurkishText.fold($0).contains("SAAT") && TurkishDate.time(in: $0) != nil } ?? dateRow
        return TurkishDate.resolve(day, time: TurkishDate.time(in: timeRow), reference: referenceDate, calendar: calendar) ?? referenceDate
    }

    /// The store name is printed first, above the address and receipt details.
    private func merchant(in rows: [String]) -> String {
        let details = ["FIS", "TARIH", "SAAT", "VKN", "VERGI", "TEL", "TOPLAM"]
        return rows.lazy
            .filter { row in !details.contains { TurkishText.tokens(row).contains($0) } }
            .map(MerchantCleaner.clean)
            .first { MerchantCleaner.isUsable($0) && TurkishText.letterCount($0) >= 3 } ?? ""
    }
}
