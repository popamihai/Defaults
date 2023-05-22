import Foundation
import Defaults
import XCTest

private let fixtureDictionary = ["0": "Hank"]

private let fixtureArray = ["Hank", "Chen"]

extension DefaultsEnum.Keys {
	fileprivate static let dictionary = Key<[String: String]>("dictionary", default: fixtureDictionary)
}

final class DefaultsDictionaryTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<[String: String]>("independentDictionaryStringKey", default: fixtureDictionary)
		XCTAssertEqual(DefaultsEnum[key]["0"], fixtureDictionary["0"])
		let newValue = "John"
		DefaultsEnum[key]["0"] = newValue
		XCTAssertEqual(DefaultsEnum[key]["0"], newValue)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<[String: String]?>("independentDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = fixtureDictionary
		XCTAssertEqual(DefaultsEnum[key]?["0"], fixtureDictionary["0"])
		DefaultsEnum[key] = nil
		XCTAssertNil(DefaultsEnum[key])
		let newValue = ["0": "Chen"]
		DefaultsEnum[key] = newValue
		XCTAssertEqual(DefaultsEnum[key]?["0"], newValue["0"])
	}

	func testNestedKey() {
		let key = DefaultsEnum.Key<[String: [String: String]]>("independentDictionaryNestedKey", default: ["0": fixtureDictionary])
		XCTAssertEqual(DefaultsEnum[key]["0"]?["0"], "Hank")
		let newName = "Chen"
		DefaultsEnum[key]["0"]?["0"] = newName
		XCTAssertEqual(DefaultsEnum[key]["0"]?["0"], newName)
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[String: [String]]>("independentDictionaryArrayKey", default: ["0": fixtureArray])
		XCTAssertEqual(DefaultsEnum[key]["0"], fixtureArray)
		let newName = "Chen"
		DefaultsEnum[key]["0"]?[0] = newName
		XCTAssertEqual(DefaultsEnum[key]["0"], [newName, fixtureArray[1]])
	}

	func testType() {
		XCTAssertEqual(DefaultsEnum[.dictionary]["0"], fixtureDictionary["0"])
		let newName = "Chen"
		DefaultsEnum[.dictionary]["0"] = newName
		XCTAssertEqual(DefaultsEnum[.dictionary]["0"], newName)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<[String: String]>("observeDictionaryKeyCombine", default: fixtureDictionary)
		let expect = expectation(description: "Observation closure being called")
		let newName = "John"

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureDictionary["0"]!, newName), (newName, fixtureDictionary["0"]!)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"])
				XCTAssertEqual(expected.1, tuples[index].1["0"])
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = newName
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<[String: String]?>("observeDictionaryOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")
		let newName = ["0": "John"]
		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		// swiftlint:disable discouraged_optional_collection
		let expectedValues: [([String: String]?, [String: String]?)] = [(nil, fixtureDictionary), (fixtureDictionary, newName), (newName, nil)]

		let cancellable = publisher.sink { actualValues in
			for (expected, actual) in zip(expectedValues, actualValues) {
				XCTAssertEqual(expected.0, actual.0)
				XCTAssertEqual(expected.1, actual.1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureDictionary
		DefaultsEnum[key] = newName
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<[String: String]>("observeDictionaryKey", default: fixtureDictionary)
		let expect = expectation(description: "Observation closure being called")
		let newName = "John"

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, fixtureDictionary)
			XCTAssertEqual(change.newValue["1"], newName)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["1"] = newName
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<[String: String]?>("observeDictionaryOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue!, fixtureDictionary)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureDictionary
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
