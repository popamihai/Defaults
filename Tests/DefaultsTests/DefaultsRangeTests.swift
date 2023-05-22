import Foundation
import Defaults
import XCTest

private struct CustomDate {
	let year: Int
	let month: Int
	let day: Int
}

extension CustomDate: DefaultsEnum.Serializable {
	public struct CustomDateBridge: DefaultsEnum.Bridge {
		public typealias Value = CustomDate
		public typealias Serializable = [Int]

		public func serialize(_ value: Value?) -> Serializable? {
			guard let value else {
				return nil
			}

			return [value.year, value.month, value.day]
		}

		public func deserialize(_ object: Serializable?) -> Value? {
			guard let object else {
				return nil
			}

			return .init(year: object[0], month: object[1], day: object[2])
		}
	}

	public static let bridge = CustomDateBridge()
}

extension CustomDate: Comparable {
	static func < (lhs: CustomDate, rhs: CustomDate) -> Bool {
		if lhs.year != rhs.year {
				return lhs.year < rhs.year
		} else if lhs.month != rhs.month {
				return lhs.month < rhs.month
		} else {
				return lhs.day < rhs.day
		}
	}

	static func == (lhs: CustomDate, rhs: CustomDate) -> Bool {
		lhs.year == rhs.year && lhs.month == rhs.month
				&& lhs.day == rhs.day
	}
}

// Fixtures:
private let fixtureRange = 0..<10
private let nextFixtureRange = 1..<20
private let fixtureDateRange = CustomDate(year: 2022, month: 4, day: 0)..<CustomDate(year: 2022, month: 5, day: 0)
private let nextFixtureDateRange = CustomDate(year: 2022, month: 6, day: 1)..<CustomDate(year: 2022, month: 7, day: 1)
private let fixtureClosedRange = 0...10
private let nextFixtureClosedRange = 1...20
private let fixtureDateClosedRange = CustomDate(year: 2022, month: 4, day: 0)...CustomDate(year: 2022, month: 5, day: 0)
private let nextFixtureDateClosedRange = CustomDate(year: 2022, month: 6, day: 1)...CustomDate(year: 2022, month: 7, day: 1)

final class DefaultsClosedRangeTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		// Test native support Range type
		let key = DefaultsEnum.Key<Range>("independentRangeKey", default: fixtureRange)
		XCTAssertEqual(fixtureRange.upperBound, DefaultsEnum[key].upperBound)
		XCTAssertEqual(fixtureRange.lowerBound, DefaultsEnum[key].lowerBound)
		DefaultsEnum[key] = nextFixtureRange
		XCTAssertEqual(nextFixtureRange.upperBound, DefaultsEnum[key].upperBound)
		XCTAssertEqual(nextFixtureRange.lowerBound, DefaultsEnum[key].lowerBound)

		// Test serializable Range type
		let dateKey = DefaultsEnum.Key<Range<CustomDate>>("independentRangeDateKey", default: fixtureDateRange)
		XCTAssertEqual(fixtureDateRange.upperBound, DefaultsEnum[dateKey].upperBound)
		XCTAssertEqual(fixtureDateRange.lowerBound, DefaultsEnum[dateKey].lowerBound)
		DefaultsEnum[dateKey] = nextFixtureDateRange
		XCTAssertEqual(nextFixtureDateRange.upperBound, DefaultsEnum[dateKey].upperBound)
		XCTAssertEqual(nextFixtureDateRange.lowerBound, DefaultsEnum[dateKey].lowerBound)

		// Test native support ClosedRange type
		let closedKey = DefaultsEnum.Key<ClosedRange>("independentClosedRangeKey", default: fixtureClosedRange)
		XCTAssertEqual(fixtureClosedRange.upperBound, DefaultsEnum[closedKey].upperBound)
		XCTAssertEqual(fixtureClosedRange.lowerBound, DefaultsEnum[closedKey].lowerBound)
		DefaultsEnum[closedKey] = nextFixtureClosedRange
		XCTAssertEqual(nextFixtureClosedRange.upperBound, DefaultsEnum[closedKey].upperBound)
		XCTAssertEqual(nextFixtureClosedRange.lowerBound, DefaultsEnum[closedKey].lowerBound)

		// Test serializable ClosedRange type
		let closedDateKey = DefaultsEnum.Key<ClosedRange<CustomDate>>("independentClosedRangeDateKey", default: fixtureDateClosedRange)
		XCTAssertEqual(fixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey].upperBound)
		XCTAssertEqual(fixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey].lowerBound)
		DefaultsEnum[closedDateKey] = nextFixtureDateClosedRange
		XCTAssertEqual(nextFixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey].upperBound)
		XCTAssertEqual(nextFixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey].lowerBound)
	}

	func testOptionalKey() {
		// Test native support Range type
		let key = DefaultsEnum.Key<Range<Int>?>("independentRangeOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = fixtureRange
		XCTAssertEqual(fixtureRange.upperBound, DefaultsEnum[key]?.upperBound)
		XCTAssertEqual(fixtureRange.lowerBound, DefaultsEnum[key]?.lowerBound)

		// Test serializable Range type
		let dateKey = DefaultsEnum.Key<Range<CustomDate>?>("independentRangeDateOptionalKey")
		XCTAssertNil(DefaultsEnum[dateKey])
		DefaultsEnum[dateKey] = fixtureDateRange
		XCTAssertEqual(fixtureDateRange.upperBound, DefaultsEnum[dateKey]?.upperBound)
		XCTAssertEqual(fixtureDateRange.lowerBound, DefaultsEnum[dateKey]?.lowerBound)

		// Test native support ClosedRange type
		let closedKey = DefaultsEnum.Key<ClosedRange<Int>?>("independentClosedRangeOptionalKey")
		XCTAssertNil(DefaultsEnum[closedKey])
		DefaultsEnum[closedKey] = fixtureClosedRange
		XCTAssertEqual(fixtureClosedRange.upperBound, DefaultsEnum[closedKey]?.upperBound)
		XCTAssertEqual(fixtureClosedRange.lowerBound, DefaultsEnum[closedKey]?.lowerBound)

		// Test serializable ClosedRange type
		let closedDateKey = DefaultsEnum.Key<ClosedRange<CustomDate>?>("independentClosedRangeDateOptionalKey")
		XCTAssertNil(DefaultsEnum[closedDateKey])
		DefaultsEnum[closedDateKey] = fixtureDateClosedRange
		XCTAssertEqual(fixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey]?.upperBound)
		XCTAssertEqual(fixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey]?.lowerBound)
	}

	func testArrayKey() {
		// Test native support Range type
		let key = DefaultsEnum.Key<[Range]>("independentRangeArrayKey", default: [fixtureRange])
		XCTAssertEqual(fixtureRange.upperBound, DefaultsEnum[key][0].upperBound)
		XCTAssertEqual(fixtureRange.lowerBound, DefaultsEnum[key][0].lowerBound)
		DefaultsEnum[key].append(nextFixtureRange)
		XCTAssertEqual(fixtureRange.upperBound, DefaultsEnum[key][0].upperBound)
		XCTAssertEqual(fixtureRange.lowerBound, DefaultsEnum[key][0].lowerBound)
		XCTAssertEqual(nextFixtureRange.upperBound, DefaultsEnum[key][1].upperBound)
		XCTAssertEqual(nextFixtureRange.lowerBound, DefaultsEnum[key][1].lowerBound)

		// Test serializable Range type
		let dateKey = DefaultsEnum.Key<[Range<CustomDate>]>("independentRangeDateArrayKey", default: [fixtureDateRange])
		XCTAssertEqual(fixtureDateRange.upperBound, DefaultsEnum[dateKey][0].upperBound)
		XCTAssertEqual(fixtureDateRange.lowerBound, DefaultsEnum[dateKey][0].lowerBound)
		DefaultsEnum[dateKey].append(nextFixtureDateRange)
		XCTAssertEqual(fixtureDateRange.upperBound, DefaultsEnum[dateKey][0].upperBound)
		XCTAssertEqual(fixtureDateRange.lowerBound, DefaultsEnum[dateKey][0].lowerBound)
		XCTAssertEqual(nextFixtureDateRange.upperBound, DefaultsEnum[dateKey][1].upperBound)
		XCTAssertEqual(nextFixtureDateRange.lowerBound, DefaultsEnum[dateKey][1].lowerBound)

		// Test native support ClosedRange type
		let closedKey = DefaultsEnum.Key<[ClosedRange]>("independentClosedRangeArrayKey", default: [fixtureClosedRange])
		XCTAssertEqual(fixtureClosedRange.upperBound, DefaultsEnum[closedKey][0].upperBound)
		XCTAssertEqual(fixtureClosedRange.lowerBound, DefaultsEnum[closedKey][0].lowerBound)
		DefaultsEnum[closedKey].append(nextFixtureClosedRange)
		XCTAssertEqual(fixtureClosedRange.upperBound, DefaultsEnum[closedKey][0].upperBound)
		XCTAssertEqual(fixtureClosedRange.lowerBound, DefaultsEnum[closedKey][0].lowerBound)
		XCTAssertEqual(nextFixtureClosedRange.upperBound, DefaultsEnum[closedKey][1].upperBound)
		XCTAssertEqual(nextFixtureClosedRange.lowerBound, DefaultsEnum[closedKey][1].lowerBound)

		// Test serializable ClosedRange type
		let closedDateKey = DefaultsEnum.Key<[ClosedRange<CustomDate>]>("independentClosedRangeDateArrayKey", default: [fixtureDateClosedRange])
		XCTAssertEqual(fixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey][0].upperBound)
		XCTAssertEqual(fixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey][0].lowerBound)
		DefaultsEnum[closedDateKey].append(nextFixtureDateClosedRange)
		XCTAssertEqual(fixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey][0].upperBound)
		XCTAssertEqual(fixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey][0].lowerBound)
		XCTAssertEqual(nextFixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey][1].upperBound)
		XCTAssertEqual(nextFixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey][1].lowerBound)
	}

	func testDictionaryKey() {
		// Test native support Range type
		let key = DefaultsEnum.Key<[String: Range]>("independentRangeDictionaryKey", default: ["0": fixtureRange])
		XCTAssertEqual(fixtureRange.upperBound, DefaultsEnum[key]["0"]?.upperBound)
		XCTAssertEqual(fixtureRange.lowerBound, DefaultsEnum[key]["0"]?.lowerBound)
		DefaultsEnum[key]["1"] = nextFixtureRange
		XCTAssertEqual(fixtureRange.upperBound, DefaultsEnum[key]["0"]?.upperBound)
		XCTAssertEqual(fixtureRange.lowerBound, DefaultsEnum[key]["0"]?.lowerBound)
		XCTAssertEqual(nextFixtureRange.upperBound, DefaultsEnum[key]["1"]?.upperBound)
		XCTAssertEqual(nextFixtureRange.lowerBound, DefaultsEnum[key]["1"]?.lowerBound)

		// Test serializable Range type
		let dateKey = DefaultsEnum.Key<[String: Range<CustomDate>]>("independentRangeDateDictionaryKey", default: ["0": fixtureDateRange])
		XCTAssertEqual(fixtureDateRange.upperBound, DefaultsEnum[dateKey]["0"]?.upperBound)
		XCTAssertEqual(fixtureDateRange.lowerBound, DefaultsEnum[dateKey]["0"]?.lowerBound)
		DefaultsEnum[dateKey]["1"] = nextFixtureDateRange
		XCTAssertEqual(fixtureDateRange.upperBound, DefaultsEnum[dateKey]["0"]?.upperBound)
		XCTAssertEqual(fixtureDateRange.lowerBound, DefaultsEnum[dateKey]["0"]?.lowerBound)
		XCTAssertEqual(nextFixtureDateRange.upperBound, DefaultsEnum[dateKey]["1"]?.upperBound)
		XCTAssertEqual(nextFixtureDateRange.lowerBound, DefaultsEnum[dateKey]["1"]?.lowerBound)

		// Test native support ClosedRange type
		let closedKey = DefaultsEnum.Key<[String: ClosedRange]>("independentClosedRangeDictionaryKey", default: ["0": fixtureClosedRange])
		XCTAssertEqual(fixtureClosedRange.upperBound, DefaultsEnum[closedKey]["0"]?.upperBound)
		XCTAssertEqual(fixtureClosedRange.lowerBound, DefaultsEnum[closedKey]["0"]?.lowerBound)
		DefaultsEnum[closedKey]["1"] = nextFixtureClosedRange
		XCTAssertEqual(fixtureClosedRange.upperBound, DefaultsEnum[closedKey]["0"]?.upperBound)
		XCTAssertEqual(fixtureClosedRange.lowerBound, DefaultsEnum[closedKey]["0"]?.lowerBound)
		XCTAssertEqual(nextFixtureClosedRange.upperBound, DefaultsEnum[closedKey]["1"]?.upperBound)
		XCTAssertEqual(nextFixtureClosedRange.lowerBound, DefaultsEnum[closedKey]["1"]?.lowerBound)

		// Test serializable ClosedRange type
		let closedDateKey = DefaultsEnum.Key<[String: ClosedRange<CustomDate>]>("independentClosedRangeDateDictionaryKey", default: ["0": fixtureDateClosedRange])
		XCTAssertEqual(fixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey]["0"]?.upperBound)
		XCTAssertEqual(fixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey]["0"]?.lowerBound)
		DefaultsEnum[closedDateKey]["1"] = nextFixtureDateClosedRange
		XCTAssertEqual(fixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey]["0"]?.upperBound)
		XCTAssertEqual(fixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey]["0"]?.lowerBound)
		XCTAssertEqual(nextFixtureDateClosedRange.upperBound, DefaultsEnum[closedDateKey]["1"]?.upperBound)
		XCTAssertEqual(nextFixtureDateClosedRange.lowerBound, DefaultsEnum[closedDateKey]["1"]?.lowerBound)
	}
}
