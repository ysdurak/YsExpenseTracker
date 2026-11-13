import XCTest
@testable import ExpenseScanner

final class MerchantCategorizerTests: XCTestCase {
    let categorizer = MerchantCategorizer()

    func testBuiltInKeywords() {
        XCTAssertEqual(categorizer.categoryIdentifier(for: "ARABICA", userRules: [:]), "food")
        XCTAssertEqual(categorizer.categoryIdentifier(for: "APPLE.COM/BI", userRules: [:]), "subscriptions")
        XCTAssertEqual(categorizer.categoryIdentifier(for: "Activision B", userRules: [:]), "games")
        XCTAssertEqual(categorizer.categoryIdentifier(for: "A101 KADIKÖY", userRules: [:]), "groceries")
        XCTAssertEqual(categorizer.categoryIdentifier(for: "Migros Sanal Market", userRules: [:]), "groceries")
        XCTAssertNil(categorizer.categoryIdentifier(for: "SHELL INCEK", userRules: [:]))
        XCTAssertNil(categorizer.categoryIdentifier(for: "ABIMOTOR", userRules: [:]))
    }

    func testUserRulesWinOverKeywords() {
        let rules = [
            MerchantCategorizer.ruleKey(for: "SHELL INCEK")!: "Ulaşım",
            MerchantCategorizer.ruleKey(for: "ARABICA")!: "Kafe"
        ]
        XCTAssertEqual(categorizer.categoryIdentifier(for: "Shell İncek", userRules: rules), "Ulaşım")
        XCTAssertEqual(categorizer.categoryIdentifier(for: "ARABICA", userRules: rules), "Kafe")
    }

    func testRuleKeyIgnoresCaseDigitsSpacesAndDottedI() {
        XCTAssertEqual(MerchantCategorizer.ruleKey(for: "Shell İncek 2"), "SHELLINCEK")
        XCTAssertEqual(MerchantCategorizer.ruleKey(for: "SHELL INCEK"), "SHELLINCEK")
        XCTAssertEqual(MerchantCategorizer.ruleKey(for: "APPLE.COM/BI"), "APPLECOMBI")
        XCTAssertNil(MerchantCategorizer.ruleKey(for: "1234"))
    }
}
