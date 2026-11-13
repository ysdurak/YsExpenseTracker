import XCTest
@testable import ExpenseScanner

final class ReceiptParserTests: XCTestCase {
    func testTypicalReceipt() {
        let lines = [
            line("MİGROS TİCARET A.Ş.", y: 0.05, width: 0.6),
            line("ATAŞEHİR MAĞAZASI", y: 0.07, width: 0.5),
            line("TARİH : 12.11.2026", y: 0.12, width: 0.4), line("SAAT : 18:42", x: 0.6, y: 0.12),
            line("FİŞ NO : 0042", y: 0.14),
            line("SÜT", y: 0.20, width: 0.1), line("*34,50", x: 0.7, y: 0.20, width: 0.15),
            line("EKMEK", y: 0.22, width: 0.1), line("*15,00", x: 0.7, y: 0.22, width: 0.15),
            line("ARA TOPLAM", y: 0.30), line("*49,50", x: 0.7, y: 0.30, width: 0.15),
            line("TOPKDV", y: 0.32), line("*0,49", x: 0.7, y: 0.32, width: 0.15),
            line("TOPLAM", y: 0.34), line("*49,50", x: 0.7, y: 0.34, width: 0.15),
            line("NAKİT", y: 0.36), line("*100,00", x: 0.7, y: 0.36, width: 0.15)
        ]
        let draft = ReceiptParser(referenceDate: date(2026, 11, 13, 9, 0), calendar: istanbul).parse(lines)

        XCTAssertEqual(draft.merchant, "MİGROS")
        XCTAssertEqual(draft.amount, 49.50)
        XCTAssertEqual(draft.date, date(2026, 11, 12, 18, 42))
    }

    func testTotalOnSameLineWithThousands() {
        let lines = [
            line("CARREFOURSA", y: 0.05),
            line("13/11/2026 20:15", y: 0.10),
            line("TOPLAM *1.234,56", y: 0.40, width: 0.8)
        ]
        let draft = ReceiptParser(referenceDate: date(2026, 11, 13), calendar: istanbul).parse(lines)

        XCTAssertEqual(draft.amount, 1234.56)
        XCTAssertEqual(draft.date, date(2026, 11, 13, 20, 15))
    }

    func testFallsBackToLargestAmountAndToday() {
        let lines = [
            line("BİM BİRLEŞİK MAĞAZALAR A.Ş.", y: 0.05, width: 0.7),
            line("DOMATES", y: 0.20), line("*34,50", x: 0.7, y: 0.20, width: 0.15),
            line("PEYNIR", y: 0.22), line("*115,00", x: 0.7, y: 0.22, width: 0.15),
            line("NAKİT", y: 0.30), line("*200,00", x: 0.7, y: 0.30, width: 0.15)
        ]
        let now = date(2026, 11, 13, 9, 30)
        let draft = ReceiptParser(referenceDate: now, calendar: istanbul).parse(lines)

        XCTAssertEqual(draft.merchant, "BİM BİRLEŞİK MAĞAZALAR")
        XCTAssertEqual(draft.amount, 115.00)
        XCTAssertEqual(draft.date, now)
    }

    func testMissingTotal() {
        let draft = ReceiptParser(referenceDate: date(2026, 11, 13), calendar: istanbul).parse([line("ŞOK MARKET", y: 0.05)])
        XCTAssertNil(draft.amount)
        XCTAssertEqual(draft.merchant, "ŞOK MARKET")
    }
}
