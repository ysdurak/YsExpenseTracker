import Foundation

/// Turns raw transaction descriptions like "SATIŞ-517040*7645-ARABICA" into a merchant name.
enum MerchantCleaner {
    private static let cardNumbers = Patterns.regex(#"\d{4,6}\*+\d{2,4}|\*{2,}\d{2,4}|^\s*\d{4}\s*-"#)
    private static let moneyWithCurrency = Patterns.regex(#"\d+(?:[.,]\d+)*\s*(TL|TRY|EUR|USD|GBP|₺|€|\$|£)(?![\p{L}])"#)
    private static let transactionWords = Patterns.regex(#"(?<![\p{L}])(SATIŞ|SATIS|SATİŞ|HARCAMA|POS)(?![\p{L}])"#)
    private static let legalSuffixes = Patterns.regex(#"(?<![\p{L}\d])(A\.?\s?Ş\.?|A\.?\s?S\.?|LTD\.?|ŞTİ\.?|STİ\.?|STI\.?|TİC\.?|TİCARET|TICARET|SAN\.?|PAZ\.?|PAZARLAMA|ANONİM|ŞİRKETİ|LİMİTED)(?![\p{L}\d])"#)
    private static let bareNumbers = Patterns.regex(#"(?<![\p{L}\d])\d+(?![\p{L}\d])"#)
    private static let separators = Patterns.regex(#"[-_*|]+"#)
    private static let foreignMoney = Patterns.regex(#"(\d+(?:[.,]\d+)*)\s*(EUR|USD|GBP|€|\$|£)(?![\p{L}])"#)

    static func clean(_ raw: String) -> String {
        var text = raw
        for pattern in [cardNumbers, moneyWithCurrency, transactionWords, legalSuffixes, bareNumbers, separators] {
            text = Patterns.removing(pattern, from: text)
        }
        let words = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return words.trimmingCharacters(in: CharacterSet(charactersIn: " ./-,:"))
    }

    /// A non-TL charge mentioned in the description, e.g. "12.99 EUR".
    static func foreignAmount(in raw: String) -> String? {
        guard let groups = Patterns.firstMatch(foreignMoney, in: raw) else { return nil }
        let symbols = ["€": "EUR", "$": "USD", "£": "GBP"]
        let currency = groups[2]!.uppercased()
        return "\(groups[1]!) \(symbols[currency] ?? currency)"
    }

    /// Whether the cleaned text looks like a name rather than OCR noise from an icon ("W E").
    static func isUsable(_ cleaned: String) -> Bool {
        TurkishText.alphanumericCount(cleaned) >= 3 && TurkishText.letterCount(cleaned) >= 1
    }
}
