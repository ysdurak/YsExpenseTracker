import Foundation

/// Reads Turkish-formatted money amounts such as "-1.234,56 TL".
enum TurkishAmount {
    private static let number = #"(\d{1,3}(?:\.\d{3})+|\d+),(\d{2})"#
    private static let currency = #"(?:\s*(?:TL|TRY|₺))?"#

    private static let signed = Patterns.regex(#"^[-−–]\s*₺?\s*"# + number + currency + "$")
    private static let unsigned = Patterns.regex(#"^₺?\s*"# + number + currency + "$")
    private static let anySign = Patterns.regex(#"^[-−–+]?\s*₺?\s*\*?\s*"# + number + currency + "$")
    private static let onReceipt = Patterns.regex(#"\*\s?(\d{1,3}(?:\.\d{3})+|\d+)[.,](\d{2})(?!\d)|(?<![\d.,])(\d{1,3}(?:\.\d{3})+|\d+),(\d{2})(?!\d)"#)

    /// A line that is only a negative amount: an outgoing transaction on a bank statement.
    static func expense(in text: String) -> Double? {
        Patterns.firstMatch(signed, in: trimmed(text)).flatMap(value)
    }

    /// A line that is only an amount with no sign.
    static func unsignedAmount(in text: String) -> Double? {
        Patterns.firstMatch(unsigned, in: trimmed(text)).flatMap(value)
    }

    /// True when the whole line is an amount, signed or not (balances, incoming money, prices).
    static func isAmount(_ text: String) -> Bool {
        Patterns.firstMatch(anySign, in: trimmed(text)) != nil
    }

    /// All amounts printed on a receipt line, e.g. "*1.234,56" or "49,50".
    static func receiptAmounts(in text: String) -> [Double] {
        Patterns.allMatches(onReceipt, in: text).compactMap { groups in
            if groups[1] != nil { return value(integer: groups[1], fraction: groups[2]) }
            return value(integer: groups[3], fraction: groups[4])
        }
    }

    private static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespaces)
    }

    private static func value(_ groups: [String?]) -> Double? {
        value(integer: groups[1], fraction: groups[2])
    }

    private static func value(integer: String?, fraction: String?) -> Double? {
        guard let integer, let fraction else { return nil }
        return Double(integer.replacingOccurrences(of: ".", with: "") + "." + fraction)
    }
}
