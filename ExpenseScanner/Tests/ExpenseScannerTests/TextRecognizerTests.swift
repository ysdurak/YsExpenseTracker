import CoreGraphics
import XCTest
@testable import ExpenseScanner

final class TextRecognizerTests: XCTestCase {
    func testDetectsRedInkOnWhite() {
        let image = stripes(ink: CGColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1))
        XCTAssertTrue(TextRecognizer.isTextReddish(in: image, box: OCRBox(x: 0, y: 0, width: 1, height: 1)))
    }

    func testBlackInkIsNotRed() {
        let image = stripes(ink: CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
        XCTAssertFalse(TextRecognizer.isTextReddish(in: image, box: OCRBox(x: 0, y: 0, width: 1, height: 1)))
    }

    /// A white image with thin vertical strokes, roughly like glyphs.
    private func stripes(ink: CGColor) -> CGImage {
        let context = CGContext(data: nil, width: 200, height: 40, bitsPerComponent: 8, bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 200, height: 40))
        context.setFillColor(ink)
        for x in stride(from: 10, to: 190, by: 12) {
            context.fill(CGRect(x: x, y: 8, width: 3, height: 24))
        }
        return context.makeImage()!
    }
}
