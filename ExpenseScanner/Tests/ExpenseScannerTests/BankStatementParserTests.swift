import XCTest
@testable import ExpenseScanner

final class BankStatementParserTests: XCTestCase {
    func testGarantiScreenshot() throws {
        let parser = BankStatementParser(referenceDate: date(2026, 11, 13, 15, 0), calendar: istanbul)
        let drafts = parser.parse(try fixture("garanti-statement"))

        XCTAssertEqual(drafts.map(\.amount), [270.00, 49.99, 756.73, 240.00])
        XCTAssertEqual(drafts.map(\.date), [
            date(2026, 11, 13, 13, 49),
            date(2026, 11, 12, 10, 29),
            date(2026, 11, 11, 12, 16),
            date(2026, 11, 11, 11, 20)
        ])
        XCTAssertEqual(drafts.map(\.merchant), ["ARABICA", "APPLE.COM/BI", "Activision B", "SHELL INCEK"])
        XCTAssertEqual(drafts.map(\.foreignAmount), [nil, nil, "12.99 EUR", nil])
    }

    func testDayHeadersApplyToRowsBelowAndIncomingIsSkipped() {
        let lines = [
            line("12 Kasım Salı", y: 0.10),
            line("MIGROS", y: 0.14), line("-120,50 TL", x: 0.75, y: 0.14, width: 0.2), line("14:05", y: 0.165, width: 0.1),
            line("SHELL", y: 0.22), line("-500,00 TL", x: 0.75, y: 0.22, width: 0.2), line("09:10", y: 0.245, width: 0.1),
            line("11 Kasım Pazartesi", y: 0.30),
            line("NETFLIX", y: 0.34), line("-229,99 TL", x: 0.75, y: 0.34, width: 0.2),
            line("MAAŞ ÖDEMESİ", y: 0.42), line("+15.000,00 TL", x: 0.75, y: 0.42, width: 0.2)
        ]
        let drafts = BankStatementParser(referenceDate: date(2026, 11, 13), calendar: istanbul).parse(lines)

        XCTAssertEqual(drafts.map(\.merchant), ["MIGROS", "SHELL", "NETFLIX"])
        XCTAssertEqual(drafts.map(\.amount), [120.50, 500.00, 229.99])
        XCTAssertEqual(drafts.map(\.date), [date(2026, 11, 12, 14, 5), date(2026, 11, 12, 9, 10), date(2026, 11, 11)])
    }

    func testRelativeDatesAndYearRollover() {
        let lines = [
            line("Bugün", y: 0.10, width: 0.1), line("YEMEKSEPETI", x: 0.2, y: 0.10), line("-85,00", x: 0.8, y: 0.10, width: 0.15),
            line("Dün", y: 0.20, width: 0.1), line("SPOTIFY", x: 0.2, y: 0.20), line("-59,99", x: 0.8, y: 0.20, width: 0.15),
            line("28 Ara", y: 0.30, width: 0.1), line("ZARA", x: 0.2, y: 0.30), line("-1.299,90", x: 0.8, y: 0.30, width: 0.15)
        ]
        let drafts = BankStatementParser(referenceDate: date(2026, 1, 5, 12, 0), calendar: istanbul).parse(lines)

        XCTAssertEqual(drafts.map(\.date), [date(2026, 1, 5), date(2026, 1, 4), date(2025, 12, 28)])
        XCTAssertEqual(drafts.map(\.amount), [85.00, 59.99, 1299.90])
    }

    func testRedUnsignedAmountsWhenNoSignedAmountsExist() {
        let lines = [
            line("13.11.2026", y: 0.10), line("MIGROS", y: 0.13), line("250,00 TL", x: 0.75, y: 0.10, width: 0.2, reddish: true),
            line("Bakiye", y: 0.16), line("5.000,00 TL", x: 0.75, y: 0.16, width: 0.2),
            line("12.11.2026", y: 0.25), line("IADE", y: 0.28), line("100,00 TL", x: 0.75, y: 0.25, width: 0.2)
        ]
        let drafts = BankStatementParser(referenceDate: date(2026, 11, 13), calendar: istanbul).parse(lines)

        XCTAssertEqual(drafts.map(\.amount), [250.00])
        XCTAssertEqual(drafts.map(\.merchant), ["MIGROS"])
    }

    func testNoTransactionsFound() {
        let lines = [line("Ana Sayfa", y: 0.9), line("Hesap ve Kart", x: 0.3, y: 0.9)]
        XCTAssertTrue(BankStatementParser(referenceDate: date(2026, 11, 13), calendar: istanbul).parse(lines).isEmpty)
    }

    func testMergingOverlappingScreenshots() {
        let a = DraftExpense(amount: 270, date: date(2026, 11, 13, 13, 49), merchant: "ARABICA")
        let b = DraftExpense(amount: 49.99, date: date(2026, 11, 12, 10, 29), merchant: "APPLE.COM/BI")
        let cutOffB = DraftExpense(amount: 49.99, date: date(2026, 11, 12, 10, 29), merchant: "")
        let c = DraftExpense(amount: 240, date: date(2026, 11, 11, 11, 20), merchant: "SHELL INCEK")
        let secondC = DraftExpense(amount: 240, date: date(2026, 11, 11, 11, 20), merchant: "SHELL INCEK")

        let merged = BankStatementParser.merge([[a, cutOffB], [b, c, secondC]])

        XCTAssertEqual(merged.map(\.merchant), ["ARABICA", "APPLE.COM/BI", "SHELL INCEK", "SHELL INCEK"])
    }
}
