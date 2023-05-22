import Foundation
import Defaults
import XCTest

private let fixtureArray = ["Hank", "Chen"]

extension DefaultsEnum.Keys {
	fileprivate static let array = Key<[String]>("array", default: fixtureArray)
}

final class DefaultsArrayTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<[String]>("independentArrayStringKey", default: fixtureArray)
		XCTAssertEqual(DefaultsEnum[key][0], fixtureArray[0])
		let newValue = "John"
		DefaultsEnum[key][0] = newValue
		XCTAssertEqual(DefaultsEnum[key][0], newValue)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<[String]?>("independentArrayOptionalStringKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = fixtureArray
		XCTAssertEqual(DefaultsEnum[key]?[0], fixtureArray[0])
		DefaultsEnum[key] = nil
		XCTAssertNil(DefaultsEnum[key])
		let newValue = ["John", "Chen"]
		DefaultsEnum[key] = newValue
		XCTAssertEqual(DefaultsEnum[key]?[0], newValue[0])
	}

	func testNestedKey() {
		let defaultValue = ["Hank", "Chen"]
		let key = DefaultsEnum.Key<[[String]]>("independentArrayNestedKey", default: [defaultValue])
		XCTAssertEqual(DefaultsEnum[key][0][0], "Hank")
		let newValue = ["Sindre", "Sorhus"]
		DefaultsEnum[key][0] = newValue
		DefaultsEnum[key].append(defaultValue)
		XCTAssertEqual(DefaultsEnum[key][0][0], newValue[0])
		XCTAssertEqual(DefaultsEnum[key][0][1], newValue[1])
		XCTAssertEqual(DefaultsEnum[key][1][0], defaultValue[0])
		XCTAssertEqual(DefaultsEnum[key][1][1], defaultValue[1])
	}

	func testDictionaryKey() {
		let defaultValue = ["0": "HankChen"]
		let key = DefaultsEnum.Key<[[String: String]]>("independentArrayDictionaryKey", default: [defaultValue])
		XCTAssertEqual(DefaultsEnum[key][0]["0"], defaultValue["0"])
		let newValue = ["0": "SindreSorhus"]
		DefaultsEnum[key][0] = newValue
		DefaultsEnum[key].append(defaultValue)
		XCTAssertEqual(DefaultsEnum[key][0]["0"], newValue["0"])
		XCTAssertEqual(DefaultsEnum[key][1]["0"], defaultValue["0"])
	}

	func testNestedDictionaryKey() {
		let defaultValue = ["0": [["0": 0]]]
		let key = DefaultsEnum.Key<[[String: [[String: Int]]]]>("independentArrayNestedDictionaryKey", default: [defaultValue])
		XCTAssertEqual(DefaultsEnum[key][0]["0"]![0]["0"], 0)
		let newValue = 1
		DefaultsEnum[key][0]["0"]![0]["0"] = newValue
		DefaultsEnum[key].append(defaultValue)
		XCTAssertEqual(DefaultsEnum[key][1]["0"]![0]["0"], 0)
		XCTAssertEqual(DefaultsEnum[key][0]["0"]![0]["0"], newValue)
	}

	func testType() {
		XCTAssertEqual(DefaultsEnum[.array][0], fixtureArray[0])
		let newName = "Hank121314"
		DefaultsEnum[.array][0] = newName
		XCTAssertEqual(DefaultsEnum[.array][0], newName)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<[String]>("observeArrayKeyCombine", default: fixtureArray)
		let newName = "Chen"
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureArray[0], newName), (newName, fixtureArray[0])].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0])
				XCTAssertEqual(expected.1, tuples[index].1[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0] = newName
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<[String]?>("observeArrayOptionalKeyCombine")
		let newName = ["Chen"]
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		// swiftlint:disable discouraged_optional_collection
		let expectedValues: [([String]?, [String]?)] = [(nil, fixtureArray), (fixtureArray, newName), (newName, nil)]

		let cancellable = publisher.sink { actualValues in
			for (expected, actual) in zip(expectedValues, actualValues) {
				XCTAssertEqual(expected.0, actual.0)
				XCTAssertEqual(expected.1, actual.1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureArray
		DefaultsEnum[key] = newName
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<[String]>("observeArrayKey", default: fixtureArray)
		let newName = "John"
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, fixtureArray)
			XCTAssertEqual(change.newValue, [fixtureArray[0], newName])
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key][1] = newName
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<[String]?>("observeArrayOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue!, fixtureArray)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureArray
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
