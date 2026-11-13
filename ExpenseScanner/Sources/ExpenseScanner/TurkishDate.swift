import Foundation

/// A calendar day read from text. The year is often missing on bank screenshots.
struct DayMatch: Equatable {
    var day = 0
    var month = 0
    var year: Int?
    /// 0 for "Bugün", 1 for "Dün".
    var daysAgo: Int?
}

enum TurkishDate {
    private static let monthNames = [
        "OCAK", "OCA", "SUBAT", "SUB", "MART", "MAR", "NISAN", "NIS", "MAYIS", "MAY", "HAZIRAN", "HAZ",
        "TEMMUZ", "TEM", "AGUSTOS", "AGU", "EYLUL", "EYL", "EKIM", "EKI", "KASIM", "KAS", "ARALIK", "ARA"
    ]
    private static let monthPrefixes = ["OCA", "SUB", "MAR", "NIS", "MAY", "HAZ", "TEM", "AGU", "EYL", "EKI", "KAS", "ARA"]
    private static let dayNames: Set = ["PAZARTESI", "SALI", "CARSAMBA", "PERSEMBE", "CUMA", "CUMARTESI", "PAZAR"]

    private static let numeric = Patterns.regex(#"(?<!\d)(\d{1,2})[./-](\d{1,2})[./-](\d{4}|\d{2})(?!\d)"#)
    private static let textual = Patterns.regex(#"(?<!\d)(\d{1,2})\s*\.?\s*("# + monthNames.joined(separator: "|") + #")(?![A-Z])\.?(?:\s+(\d{4})(?!\d))?"#)
    private static let relative = Patterns.regex(#"(?<![A-Z])(BUGUN|DUN)(?![A-Z])"#)
    private static let clock = Patterns.regex(#"(?<![\d.,])([01]?\d|2[0-3])[:.]([0-5]\d)(?![\d.,])"#)

    static func day(in text: String) -> DayMatch? {
        let folded = TurkishText.fold(text)
        if let groups = Patterns.firstMatch(numeric, in: folded),
           let day = Int(groups[1]!), let month = Int(groups[2]!), var year = Int(groups[3]!),
           (1...31).contains(day), (1...12).contains(month) {
            if year < 100 { year += 2000 }
            return DayMatch(day: day, month: month, year: year)
        }
        if let groups = Patterns.firstMatch(textual, in: folded),
           let day = Int(groups[1]!), (1...31).contains(day),
           let month = monthPrefixes.firstIndex(of: String(groups[2]!.prefix(3))) {
            return DayMatch(day: day, month: month + 1, year: groups[3].flatMap { Int($0) })
        }
        if let groups = Patterns.firstMatch(relative, in: folded) {
            return DayMatch(daysAgo: groups[1] == "BUGUN" ? 0 : 1)
        }
        return nil
    }

    static func time(in text: String) -> (hour: Int, minute: Int)? {
        guard let groups = Patterns.firstMatch(clock, in: text) else { return nil }
        return (Int(groups[1]!)!, Int(groups[2]!)!)
    }

    /// True when a line only holds date parts like "13", "KAS", "2026", "Salı" or "13:49".
    static func isDateFragment(_ text: String) -> Bool {
        let tokens = TurkishText.tokens(text)
        return !tokens.isEmpty && tokens.allSatisfy { token in
            token.allSatisfy(\.isNumber) || monthNames.contains(token) || dayNames.contains(token)
                || token == "BUGUN" || token == "DUN"
        }
    }

    /// Turns a day match into a date. A missing year is taken from the reference date,
    /// stepping back a year when that would land in the future (a "28 Ara" seen in January).
    static func resolve(_ match: DayMatch, time: (hour: Int, minute: Int)?, reference: Date, calendar: Calendar) -> Date? {
        let day: Date
        if let daysAgo = match.daysAgo {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: reference)) else { return nil }
            day = date
        } else if let year = match.year {
            guard let date = validDate(year: year, month: match.month, day: match.day, calendar: calendar) else { return nil }
            day = date
        } else {
            let year = calendar.component(.year, from: reference)
            guard let thisYear = validDate(year: year, month: match.month, day: match.day, calendar: calendar) else { return nil }
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: reference)!
            day = thisYear > tomorrow ? validDate(year: year - 1, month: match.month, day: match.day, calendar: calendar) ?? thisYear : thisYear
        }
        guard let time else { return day }
        return calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: day)
    }

    private static func validDate(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)),
              calendar.component(.day, from: date) == day else { return nil }
        return date
    }
}
