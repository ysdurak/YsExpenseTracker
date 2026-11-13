import Foundation
@testable import ExpenseScanner

let istanbul: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!
    return calendar
}()

func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    istanbul.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

func line(_ text: String, x: Double = 0.05, y: Double, width: Double = 0.3, height: Double = 0.012, reddish: Bool = false) -> OCRLine {
    OCRLine(text: text, box: OCRBox(x: x, y: y, width: width, height: height), isReddish: reddish)
}

func fixture(_ name: String) throws -> [OCRLine] {
    let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")!
    return try JSONDecoder().decode([OCRLine].self, from: Data(contentsOf: url))
}
