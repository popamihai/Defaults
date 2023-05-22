import Foundation
import Defaults
import XCTest

private enum FixtureEnum: String, DefaultsEnum.Serializable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

extension DefaultsEnum.Keys {
	fileprivate static let `enum` = Key<FixtureEnum>("enum", default: .tenMinutes)
	fileprivate static let enumArray = Key<[FixtureEnum]>("array_enum", default: [.tenMinutes])
	fileprivate static let enumDictionary = Key<[String: FixtureEnum]>("dictionary_enum", default: ["0": .tenMinutes])
}

final class DefaultsEnumTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<FixtureEnum>("independentEnumKey", default: .tenMinutes)
		XCTAssertEqual(DefaultsEnum[key], .tenMinutes)
		DefaultsEnum[key] = .halfHour
		XCTAssertEqual(DefaultsEnum[key], .halfHour)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<FixtureEnum?>("independentEnumOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = .tenMinutes
		XCTAssertEqual(DefaultsEnum[key], .tenMinutes)
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[FixtureEnum]>("independentEnumArrayKey", default: [.tenMinutes])
		XCTAssertEqual(DefaultsEnum[key][0], .tenMinutes)
		DefaultsEnum[key].append(.halfHour)
		XCTAssertEqual(DefaultsEnum[key][0], .tenMinutes)
		XCTAssertEqual(DefaultsEnum[key][1], .halfHour)
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[FixtureEnum]?>("independentEnumArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [.tenMinutes]
		DefaultsEnum[key]?.append(.halfHour)
		XCTAssertEqual(DefaultsEnum[key]?[0], .tenMinutes)
		XCTAssertEqual(DefaultsEnum[key]?[1], .halfHour)
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[FixtureEnum]]>("independentEnumNestedArrayKey", default: [[.tenMinutes]])
		XCTAssertEqual(DefaultsEnum[key][0][0], .tenMinutes)
		DefaultsEnum[key][0].append(.halfHour)
		DefaultsEnum[key].append([.oneHour])
		XCTAssertEqual(DefaultsEnum[key][0][1], .halfHour)
		XCTAssertEqual(DefaultsEnum[key][1][0], .oneHour)
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: FixtureEnum]]>("independentEnumArrayDictionaryKey", default: [["0": .tenMinutes]])
		XCTAssertEqual(DefaultsEnum[key][0]["0"], .tenMinutes)
		DefaultsEnum[key][0]["1"] = .halfHour
		DefaultsEnum[key].append(["0": .oneHour])
		XCTAssertEqual(DefaultsEnum[key][0]["1"], .halfHour)
		XCTAssertEqual(DefaultsEnum[key][1]["0"], .oneHour)
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: FixtureEnum]>("independentEnumDictionaryKey", default: ["0": .tenMinutes])
		XCTAssertEqual(DefaultsEnum[key]["0"], .tenMinutes)
		DefaultsEnum[key]["1"] = .halfHour
		XCTAssertEqual(DefaultsEnum[key]["0"], .tenMinutes)
		XCTAssertEqual(DefaultsEnum[key]["1"], .halfHour)
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: FixtureEnum]?>("independentEnumDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": .tenMinutes]
		XCTAssertEqual(DefaultsEnum[key]?["0"], .tenMinutes)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [FixtureEnum]]>("independentEnumDictionaryKey", default: ["0": [.tenMinutes]])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], .tenMinutes)
		DefaultsEnum[key]["0"]?.append(.halfHour)
		DefaultsEnum[key]["1"] = [.oneHour]
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1], .halfHour)
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0], .oneHour)
	}

	func testType() {
		XCTAssertEqual(DefaultsEnum[.enum], .tenMinutes)
		DefaultsEnum[.enum] = .halfHour
		XCTAssertEqual(DefaultsEnum[.enum], .halfHour)
	}

	func testArrayType() {
		XCTAssertEqual(DefaultsEnum[.enumArray][0], .tenMinutes)
		DefaultsEnum[.enumArray][0] = .oneHour
		XCTAssertEqual(DefaultsEnum[.enumArray][0], .oneHour)
	}

	func testDictionaryType() {
		XCTAssertEqual(DefaultsEnum[.enumDictionary]["0"], .tenMinutes)
		DefaultsEnum[.enumDictionary]["0"] = .halfHour
		XCTAssertEqual(DefaultsEnum[.enumDictionary]["0"], .halfHour)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<FixtureEnum>("observeEnumKeyCombine", default: .tenMinutes)
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(FixtureEnum, FixtureEnum)] = [(.tenMinutes, .halfHour), (.halfHour, .oneHour), (.oneHour, .tenMinutes)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = .tenMinutes
		DefaultsEnum[key] = .halfHour
		DefaultsEnum[key] = .oneHour
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<FixtureEnum?>("observeEnumOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(4)

		let expectedValue: [(FixtureEnum?, FixtureEnum?)] = [(nil, .tenMinutes), (.tenMinutes, .halfHour), (.halfHour, .oneHour), (.oneHour, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = .tenMinutes
		DefaultsEnum[key] = .halfHour
		DefaultsEnum[key] = .oneHour
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[FixtureEnum]>("observeEnumArrayKeyCombine", default: [.tenMinutes])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(FixtureEnum, FixtureEnum)] = [(.tenMinutes, .halfHour), (.halfHour, .oneHour)]


		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0])
				XCTAssertEqual(expected.1, tuples[index].1[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0] = .halfHour
		DefaultsEnum[key][0] = .oneHour
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: FixtureEnum]>("observeEnumDictionaryKeyCombine", default: ["0": .tenMinutes])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(FixtureEnum, FixtureEnum)] = [(.tenMinutes, .halfHour), (.halfHour, .oneHour)]


		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"])
				XCTAssertEqual(expected.1, tuples[index].1["0"])
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = .halfHour
		DefaultsEnum[key]["0"] = .oneHour
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<FixtureEnum>("observeEnumKey", default: .tenMinutes)
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, .tenMinutes)
			XCTAssertEqual(change.newValue, .halfHour)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = .halfHour
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<FixtureEnum?>("observeEnumOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue, .tenMinutes)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = .tenMinutes
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[FixtureEnum]>("observeEnumArrayKey", default: [.tenMinutes])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0], .tenMinutes)
			XCTAssertEqual(change.newValue[1], .halfHour)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key].append(.halfHour)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKey() {
		let key = DefaultsEnum.Key<[String: FixtureEnum]>("observeEnumDictionaryKey", default: ["0": .tenMinutes])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue["0"], .tenMinutes)
			XCTAssertEqual(change.newValue["1"], .halfHour)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["1"] = .halfHour
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
