// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ExpenseScanner",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ExpenseScanner", targets: ["ExpenseScanner"])
    ],
    targets: [
        .target(name: "ExpenseScanner"),
        .testTarget(
            name: "ExpenseScannerTests",
            dependencies: ["ExpenseScanner"],
            resources: [.copy("Fixtures")]
        )
    ]
)
