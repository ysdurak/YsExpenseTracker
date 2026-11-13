import Foundation

/// Finds outgoing transactions on a screenshot of any bank's transaction list.
///
/// Every negative amount is an anchor for one transaction. The screen is cut into one horizontal
/// band per anchor, at the widest empty gap between neighbouring anchors, and each band's lines
/// give that transaction its date and merchant. Lines outside all bands (filters, tab bars) are ignored.
public struct BankStatementParser {
    public var referenceDate: Date
    public var calendar: Calendar

    public init(referenceDate: Date = Date(), calendar: Calendar = .current) {
        self.referenceDate = referenceDate
        self.calendar = calendar
    }

    public func parse(_ lines: [OCRLine]) -> [DraftExpense] {
        let lines = lines.sorted { $0.box.minY < $1.box.minY }
        let anchors = findAnchors(in: lines)
        guard !anchors.isEmpty else { return [] }

        let bands = Self.bands(for: anchors.map(\.line), in: lines)
        let rowDates = bands.map { firstDate(in: $0) }
        let usesDayHeaders = rowDates.contains { $0 == nil }
        let dayHeaders = usesDayHeaders ? lines.compactMap { line in dateOfChain(startingAt: line, in: lines).map { (line, $0) } } : []
        let labels = Self.repeatedLabels(in: bands)

        return zip(anchors, zip(bands, rowDates)).map { anchor, bandAndDate in
            let (band, rowDate) = bandAndDate
            var day = rowDate?.day
            if usesDayHeaders {
                day = dayHeaders.last { $0.0.box.minY <= anchor.line.box.midY }?.1.day
            }
            let time = rowDate?.time ?? band.lazy.compactMap { TurkishDate.time(in: $0.text) }.first
            let date = day.flatMap { TurkishDate.resolve($0, time: time, reference: referenceDate, calendar: calendar) }
            let merchantLine = Self.merchantLine(in: band, excluding: anchor.line, labels: labels)
            return DraftExpense(
                amount: anchor.amount,
                date: date,
                merchant: merchantLine.map { MerchantCleaner.clean($0.text) } ?? "",
                foreignAmount: band.lazy.compactMap { MerchantCleaner.foreignAmount(in: $0.text) }.first
            )
        }
    }

    /// Joins the transactions of several overlapping screenshots of one list.
    /// A transaction already seen on an earlier screenshot (same amount, same minute) is kept once,
    /// with whichever copy has the longer merchant name.
    public static func merge(_ pages: [[DraftExpense]]) -> [DraftExpense] {
        var result: [DraftExpense] = []
        for page in pages {
            let earlierCount = result.count
            var claimed = Set<Int>()
            for draft in page {
                if let index = (0..<earlierCount).first(where: { !claimed.contains($0) && isSameTransaction(result[$0], draft) }) {
                    claimed.insert(index)
                    if draft.merchant.count > result[index].merchant.count { result[index] = draft }
                } else {
                    result.append(draft)
                }
            }
        }
        return result
    }

    private static func isSameTransaction(_ a: DraftExpense, _ b: DraftExpense) -> Bool {
        guard let amountA = a.amount, let amountB = b.amount, abs(amountA - amountB) < 0.005 else { return false }
        guard let dateA = a.date, let dateB = b.date else { return a.merchant == b.merchant }
        return abs(dateA.timeIntervalSince(dateB)) < 60
    }

    // MARK: - Anchors and bands

    private struct Anchor {
        var line: OCRLine
        var amount: Double
    }

    private func findAnchors(in lines: [OCRLine]) -> [Anchor] {
        let signed = lines.compactMap { line in TurkishAmount.expense(in: line.text).map { Anchor(line: line, amount: $0) } }
        if !signed.isEmpty { return signed }
        // Some banks print expenses in red without a minus sign.
        return lines.compactMap { line in
            guard line.isReddish, let amount = TurkishAmount.unsignedAmount(in: line.text) else { return nil }
            return Anchor(line: line, amount: amount)
        }
    }

    private static func bands(for anchors: [OCRLine], in lines: [OCRLine]) -> [[OCRLine]] {
        let ranges: [(top: Double, bottom: Double)]
        if anchors.count == 1 {
            ranges = [cluster(around: anchors[0], in: lines)]
        } else {
            let cuts = zip(anchors, anchors.dropFirst()).map { cut(between: $0, and: $1, in: lines) }
            let above = median(zip(anchors.dropFirst(), cuts).map { $0.box.minY - $1 })
            let below = median(zip(anchors, cuts).map { $1 - $0.box.minY })
            let tops = [anchors[0].box.minY - above] + cuts
            let bottoms = cuts + [anchors[anchors.count - 1].box.minY + below]
            ranges = Array(zip(tops, bottoms))
        }
        return ranges.map { range in lines.filter { $0.box.midY >= range.top && $0.box.midY < range.bottom } }
    }

    /// The middle of the widest vertical gap between two neighbouring anchors' rows.
    private static func cut(between upper: OCRLine, and lower: OCRLine, in lines: [OCRLine]) -> Double {
        let between = lines.filter { $0.box.midY >= upper.box.minY && $0.box.midY <= lower.box.maxY }
        var reach = upper.box.maxY
        var best = (gap: 0.0, cut: (upper.box.maxY + lower.box.minY) / 2)
        for line in between.sorted(by: { $0.box.minY < $1.box.minY }) {
            if line.box.minY > reach, line.box.minY - reach > best.gap {
                best = (line.box.minY - reach, (reach + line.box.minY) / 2)
            }
            reach = max(reach, line.box.maxY)
        }
        return best.cut
    }

    /// With a single anchor there is no neighbour to measure against, so take the lines that sit close together around it.
    private static func cluster(around anchor: OCRLine, in lines: [OCRLine]) -> (top: Double, bottom: Double) {
        let maxGap = anchor.box.height * 3
        var top = anchor.box.minY
        var bottom = anchor.box.maxY
        var grew = true
        while grew {
            grew = false
            for line in lines where line.box.minY < top || line.box.maxY > bottom {
                let gap = line.box.minY > bottom ? line.box.minY - bottom : (line.box.maxY < top ? top - line.box.maxY : 0)
                if gap <= maxGap {
                    top = min(top, line.box.minY)
                    bottom = max(bottom, line.box.maxY)
                    grew = true
                }
            }
        }
        return (top, bottom + 0.0001)
    }

    private static func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        let middle = sorted.count / 2
        return sorted.count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
    }

    // MARK: - Dates

    private typealias ChainDate = (day: DayMatch, time: (hour: Int, minute: Int)?)

    private func firstDate(in band: [OCRLine]) -> ChainDate? {
        band.lazy.compactMap { dateOfChain(startingAt: $0, in: band) }.first
    }

    /// Reads a date from a line plus the lines stacked under it, so "13" / "KAS" / "2026" / "13:49" read as one date.
    private func dateOfChain(startingAt start: OCRLine, in lines: [OCRLine]) -> ChainDate? {
        let slack = start.box.width * 0.25
        let stacked = lines.filter { line in
            line.box.minY > start.box.minY
                && line.box.minY - start.box.maxY < start.box.height * 3
                && line.box.midX >= start.box.minX - slack && line.box.midX <= start.box.maxX + slack
        }
        let text = ([start] + stacked).map(\.text).joined(separator: " ")
        guard let day = TurkishDate.day(in: text) else { return nil }
        return (day, TurkishDate.time(in: text))
    }

    // MARK: - Merchant

    /// Texts that show up in most rows ("Alışveriş", "İşlem Sonu Bakiye") are labels, not merchants.
    private static func repeatedLabels(in bands: [[OCRLine]]) -> Set<String> {
        guard bands.count >= 2 else { return [] }
        var counts: [String: Int] = [:]
        for band in bands {
            for key in Set(band.map { labelKey($0.text) }) where !key.isEmpty {
                counts[key, default: 0] += 1
            }
        }
        return Set(counts.filter { $0.value * 2 > bands.count }.keys)
    }

    private static func labelKey(_ text: String) -> String {
        TurkishText.fold(text).filter(\.isLetter)
    }

    private static func merchantLine(in band: [OCRLine], excluding anchor: OCRLine, labels: Set<String>) -> OCRLine? {
        let candidates = band.filter { line in
            line != anchor && !TurkishAmount.isAmount(line.text) && !TurkishDate.isDateFragment(line.text)
                && MerchantCleaner.isUsable(MerchantCleaner.clean(line.text))
        }
        let unlabeled = candidates.filter { !labels.contains(labelKey($0.text)) }
        let pool = unlabeled.isEmpty ? candidates : unlabeled
        // The longest name wins; ties go to the line nearest the top.
        return pool.enumerated().max { a, b in
            let lettersA = TurkishText.letterCount(MerchantCleaner.clean(a.element.text))
            let lettersB = TurkishText.letterCount(MerchantCleaner.clean(b.element.text))
            return lettersA != lettersB ? lettersA < lettersB : a.offset > b.offset
        }?.element
    }
}
