import SwiftUI
import Defaults
import XCTest

@available(iOS 15, tvOS 15, watchOS 8, *)
final class DefaultsColorTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testPreservesColorSpace() {
		let fixture = Color(.displayP3, red: 1, green: 0.3, blue: 0.7, opacity: 1)
		let key = DefaultsEnum.Key<Color?>("independentColorPreservesColorSpaceKey")
		DefaultsEnum[key] = fixture
		XCTAssertEqual(DefaultsEnum[key]?.cgColor?.colorSpace, fixture.cgColor?.colorSpace)
		XCTAssertEqual(DefaultsEnum[key]?.cgColor, fixture.cgColor)
	}
}
