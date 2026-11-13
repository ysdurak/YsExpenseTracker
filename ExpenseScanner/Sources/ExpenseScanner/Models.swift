import Foundation

/// A normalized bounding box with its origin at the top-left of the image (0...1 on both axes).
public struct OCRBox: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    var minX: Double { x }
    var maxX: Double { x + width }
    var midX: Double { x + width / 2 }
    var minY: Double { y }
    var maxY: Double { y + height }
    var midY: Double { y + height / 2 }
}

/// One line of text recognized in an image.
public struct OCRLine: Codable, Equatable, Sendable {
    public var text: String
    public var box: OCRBox
    /// True when the text is drawn in red. Only measured for amount-like lines.
    public var isReddish: Bool

    public init(text: String, box: OCRBox, isReddish: Bool = false) {
        self.text = text
        self.box = box
        self.isReddish = isReddish
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        box = try container.decode(OCRBox.self, forKey: .box)
        isReddish = try container.decodeIfPresent(Bool.self, forKey: .isReddish) ?? false
    }
}

/// An expense read from an image, before the user reviews it.
public struct DraftExpense: Equatable, Sendable {
    /// Amount in TL. Nil when no amount could be read.
    public var amount: Double?
    /// Nil when no date could be read.
    public var date: Date?
    public var merchant: String
    /// The original charge when it was made in another currency, e.g. "12.99 EUR".
    public var foreignAmount: String?

    public init(amount: Double?, date: Date?, merchant: String, foreignAmount: String? = nil) {
        self.amount = amount
        self.date = date
        self.merchant = merchant
        self.foreignAmount = foreignAmount
    }
}
