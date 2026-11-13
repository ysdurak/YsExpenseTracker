import CoreGraphics
import ImageIO
import Vision

/// Runs Apple Vision text recognition on-device and returns lines the parsers understand.
public enum TextRecognizer {
    public static func recognize(_ image: CGImage, orientation: CGImagePropertyOrientation = .up) async throws -> [OCRLine] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { observation -> OCRLine? in
                    guard let text = observation.topCandidates(1).first?.string else { return nil }
                    let box = observation.boundingBox
                    var line = OCRLine(text: text, box: OCRBox(x: box.minX, y: 1 - box.maxY, width: box.width, height: box.height))
                    // Color is only needed for banks that show expenses in red; the pixels line up only for upright images.
                    if orientation == .up, TurkishAmount.unsignedAmount(in: text) != nil {
                        line.isReddish = isTextReddish(in: image, box: line.box)
                    }
                    return line
                }
                continuation.resume(returning: lines)
            }
            request.recognitionLevel = .accurate
            // Language correction "fixes" merchant names and card numbers into dictionary words.
            request.usesLanguageCorrection = false
            if (try? request.supportedRecognitionLanguages())?.contains("tr-TR") == true {
                request.recognitionLanguages = ["tr-TR"]
            }
            do {
                try VNImageRequestHandler(cgImage: image, orientation: orientation).perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Compares the text pixels with the background: the pixels furthest from the most common color are the glyphs.
    static func isTextReddish(in image: CGImage, box: OCRBox) -> Bool {
        let rect = CGRect(
            x: box.x * Double(image.width), y: box.y * Double(image.height),
            width: box.width * Double(image.width), height: box.height * Double(image.height)
        ).integral
        guard let crop = image.cropping(to: rect), crop.width > 0, crop.height > 0 else { return false }

        let width = min(crop.width, 120)
        let height = max(1, crop.height * width / crop.width)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else { return false }
        context.draw(crop, in: CGRect(x: 0, y: 0, width: width, height: height))

        let colors = stride(from: 0, to: pixels.count, by: 4).map { (Int(pixels[$0]), Int(pixels[$0 + 1]), Int(pixels[$0 + 2])) }
        var buckets: [Int: Int] = [:]
        for (r, g, b) in colors { buckets[(r / 32) << 6 | (g / 32) << 3 | b / 32, default: 0] += 1 }
        guard let background = buckets.max(by: { $0.value < $1.value })?.key else { return false }
        let bg = ((background >> 6) * 32 + 16, ((background >> 3) & 7) * 32 + 16, (background & 7) * 32 + 16)

        let ink = colors.filter { abs($0.0 - bg.0) + abs($0.1 - bg.1) + abs($0.2 - bg.2) > 150 }
        guard ink.count >= 5 else { return false }
        let r = Double(ink.map(\.0).reduce(0, +)) / Double(ink.count)
        let g = Double(ink.map(\.1).reduce(0, +)) / Double(ink.count)
        let b = Double(ink.map(\.2).reduce(0, +)) / Double(ink.count)
        return r > 120 && r > g * 1.6 && r > b * 1.6
    }
}
