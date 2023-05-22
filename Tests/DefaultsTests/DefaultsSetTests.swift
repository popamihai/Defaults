import Foundation
import Defaults
import XCTest

private let fixtureSet = Set(1...5)

extension DefaultsEnum.Keys {
	fileprivate static let set = Key<Set<Int>>("setInt", default: fixtureSet)
}

final class DefaultsSetTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<Set<Int>>("independentSetKey", default: fixtureSet)
		XCTAssertEqual(DefaultsEnum[key].count, fixtureSet.count)
		DefaultsEnum[key].insert(6)
		XCTAssertEqual(DefaultsEnum[key], Set(1...6))
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<Set<Int>?>("independentSetOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = fixtureSet
		XCTAssertEqual(DefaultsEnum[key]?.count, fixtureSet.count)
		DefaultsEnum[key]?.insert(6)
		XCTAssertEqual(DefaultsEnum[key], Set(1...6))
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[Set<Int>]>("independentSetArrayKey", default: [fixtureSet])
		XCTAssertEqual(DefaultsEnum[key][0].count, fixtureSet.count)
		DefaultsEnum[key][0].insert(6)
		XCTAssertEqual(DefaultsEnum[key][0], Set(1...6))
		DefaultsEnum[key].append(Set(1...4))
		XCTAssertEqual(DefaultsEnum[key][1], Set(1...4))
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: Set<Int>]>("independentSetArrayKey", default: ["0": fixtureSet])
		XCTAssertEqual(DefaultsEnum[key]["0"]?.count, fixtureSet.count)
		DefaultsEnum[key]["0"]?.insert(6)
		XCTAssertEqual(DefaultsEnum[key]["0"], Set(1...6))
		DefaultsEnum[key]["1"] = Set(1...4)
		XCTAssertEqual(DefaultsEnum[key]["1"], Set(1...4))
	}
}
