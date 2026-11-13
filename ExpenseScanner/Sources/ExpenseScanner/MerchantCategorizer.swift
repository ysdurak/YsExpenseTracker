import Foundation

/// Picks a category for a merchant: the user's own corrections first, then a built-in keyword list.
public struct MerchantCategorizer {
    /// Keywords for the app's default category identifiers.
    public static let builtInKeywords: [String: [String]] = [
        "groceries": ["MİGROS", "BİM", "A101", "ŞOK", "CARREFOUR", "FİLE", "MACROCENTER"],
        "food": ["YEMEKSEPETİ", "GETİR", "TRENDYOL YEMEK", "STARBUCKS", "ARABICA", "BURGER KING", "MCDONALDS"],
        "games": ["STEAM", "ACTIVISION", "PLAYSTATION", "EPIC GAMES"],
        "subscriptions": ["APPLE.COM/BI", "NETFLIX", "SPOTIFY", "YOUTUBE", "DISNEY"],
        "bills": ["TURKCELL", "VODAFONE", "TÜRK TELEKOM", "ENERJİSA", "İGDAŞ", "İSKİ"],
        "clothing": ["ZARA", "LCW", "H&M", "DEFACTO", "KOTON"],
        "technology": ["MEDIAMARKT", "TEKNOSA", "VATAN"]
    ]

    private let keywords: [(identifier: String, phrase: String, compact: String)]

    public init(keywords: [String: [String]] = MerchantCategorizer.builtInKeywords) {
        self.keywords = keywords.sorted { $0.key < $1.key }.flatMap { identifier, words in
            words.map { word in
                let tokens = TurkishText.tokens(word)
                return (identifier, " " + tokens.joined(separator: " ") + " ", tokens.joined())
            }
        }
    }

    /// The Firestore document id for a merchant's rule: folded to uppercase ASCII letters, so
    /// "Shell İncek 2" and "SHELL INCEK" share one rule. Nil when nothing usable is left.
    public static func ruleKey(for merchant: String) -> String? {
        let key = TurkishText.fold(merchant).filter { $0.isLetter }
        return key.isEmpty ? nil : key
    }

    /// The category identifier for a merchant, or nil when nothing matches.
    public func categoryIdentifier(for merchant: String, userRules: [String: String]) -> String? {
        if let key = Self.ruleKey(for: merchant), let identifier = userRules[key] {
            return identifier
        }
        let tokens = TurkishText.tokens(merchant)
        let phrase = " " + tokens.joined(separator: " ") + " "
        let compact = tokens.joined()
        // Short keywords must match whole words, so "BİM" does not match inside "ABIMOTOR".
        return keywords.first { keyword in
            phrase.contains(keyword.phrase) || (keyword.compact.count >= 5 && compact.contains(keyword.compact))
        }?.identifier
    }
}
