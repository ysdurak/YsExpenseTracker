import Foundation

enum TurkishText {
    static let locale = Locale(identifier: "tr_TR")

    /// Uppercases with Turkish rules and drops diacritics, so "İşlem", "Işlem" and "ISLEM" all become "ISLEM".
    static func fold(_ text: String) -> String {
        text.uppercased(with: locale).folding(options: .diacriticInsensitive, locale: locale)
    }

    /// Folded words made of letters and digits only.
    static func tokens(_ text: String) -> [String] {
        fold(text).split { !$0.isLetter && !$0.isNumber }.map(String.init)
    }

    static func letterCount(_ text: String) -> Int {
        text.filter(\.isLetter).count
    }

    static func alphanumericCount(_ text: String) -> Int {
        text.filter { $0.isLetter || $0.isNumber }.count
    }
}

enum Patterns {
    static func regex(_ pattern: String) -> NSRegularExpression {
        try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }

    static func firstMatch(_ regex: NSRegularExpression, in text: String) -> [String?]? {
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }
        return (0..<match.numberOfRanges).map { index in
            Range(match.range(at: index), in: text).map { String(text[$0]) }
        }
    }

    static func allMatches(_ regex: NSRegularExpression, in text: String) -> [[String?]] {
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).map { match in
            (0..<match.numberOfRanges).map { index in
                Range(match.range(at: index), in: text).map { String(text[$0]) }
            }
        }
    }

    static func removing(_ regex: NSRegularExpression, from text: String) -> String {
        regex.stringByReplacingMatches(in: text, range: NSRange(text.startIndex..., in: text), withTemplate: " ")
    }
}
