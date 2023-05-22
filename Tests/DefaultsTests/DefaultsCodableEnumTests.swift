import Foundation
import Defaults
import XCTest

private enum FixtureCodableEnum: String, Hashable, Codable, DefaultsEnum.Serializable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

private enum FixtureCodableEnumPreferRawRepresentable: Int, Hashable, Codable, DefaultsEnum.Serializable, DefaultsEnum.PreferRawRepresentable {
	case tenMinutes = 10
	case halfHour = 30
	case oneHour = 60
}

extension DefaultsEnum.Keys {
	fileprivate static let codableEnum = Key<FixtureCodableEnum>("codable_enum", default: .oneHour)
	fileprivate static let codableEnumArray = Key<[FixtureCodableEnum]>("codable_enum", default: [.oneHour])
	fileprivate static let codableEnumDictionary = Key<[String: FixtureCodableEnum]>("codable_enum", default: ["0": .oneHour])
}

final class DefaultsCodableEnumTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<FixtureCodableEnum>("independentCodableEnumKey", default: .tenMinutes)
		XCTAssertEqual(DefaultsEnum[key], .tenMinutes)
		DefaultsEnum[key] = .halfHour
		XCTAssertEqual(DefaultsEnum[key], .halfHour)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<FixtureCodableEnum?>("independentCodableEnumOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = .tenMinutes
		XCTAssertEqual(DefaultsEnum[key], .tenMinutes)
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[FixtureCodableEnum]>("independentCodableEnumArrayKey", default: [.tenMinutes])
		XCTAssertEqual(DefaultsEnum[key][0], .tenMinutes)
		DefaultsEnum[key][0] = .halfHour
		XCTAssertEqual(DefaultsEnum[key][0], .halfHour)
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[FixtureCodableEnum]?>("independentCodableEnumArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [.halfHour]
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[FixtureCodableEnum]]>("independentCodableEnumNestedArrayKey", default: [[.tenMinutes]])
		XCTAssertEqual(DefaultsEnum[key][0][0], .tenMinutes)
		DefaultsEnum[key].append([.halfHour])
		DefaultsEnum[key][0].append(.oneHour)
		XCTAssertEqual(DefaultsEnum[key][1][0], .halfHour)
		XCTAssertEqual(DefaultsEnum[key][0][1], .oneHour)
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: FixtureCodableEnum]]>("independentCodableEnumArrayDictionaryKey", default: [["0": .tenMinutes]])
		XCTAssertEqual(DefaultsEnum[key][0]["0"], .tenMinutes)
		DefaultsEnum[key][0]["1"] = .halfHour
		DefaultsEnum[key].append(["0": .oneHour])
		XCTAssertEqual(DefaultsEnum[key][0]["1"], .halfHour)
		XCTAssertEqual(DefaultsEnum[key][1]["0"], .oneHour)
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: FixtureCodableEnum]>("independentCodableEnumDictionaryKey", default: ["0": .tenMinutes])
		XCTAssertEqual(DefaultsEnum[key]["0"], .tenMinutes)
		DefaultsEnum[key]["1"] = .halfHour
		DefaultsEnum[key]["0"] = .oneHour
		XCTAssertEqual(DefaultsEnum[key]["0"], .oneHour)
		XCTAssertEqual(DefaultsEnum[key]["1"], .halfHour)
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: FixtureCodableEnum]?>("independentCodableEnumDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": .tenMinutes]
		DefaultsEnum[key]?["1"] = .halfHour
		XCTAssertEqual(DefaultsEnum[key]?["0"], .tenMinutes)
		XCTAssertEqual(DefaultsEnum[key]?["1"], .halfHour)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [FixtureCodableEnum]]>("independentCodableEnumDictionaryArrayKey", default: ["0": [.tenMinutes]])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], .tenMinutes)
		DefaultsEnum[key]["0"]?.append(.halfHour)
		DefaultsEnum[key]["1"] = [.oneHour]
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], .tenMinutes)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1], .halfHour)
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0], .oneHour)
	}

	func testType() {
		XCTAssertEqual(DefaultsEnum[.codableEnum], .oneHour)
		DefaultsEnum[.codableEnum] = .tenMinutes
		XCTAssertEqual(DefaultsEnum[.codableEnum], .tenMinutes)
	}

	func testArrayType() {
		XCTAssertEqual(DefaultsEnum[.codableEnumArray][0], .oneHour)
		DefaultsEnum[.codableEnumArray].append(.halfHour)
		XCTAssertEqual(DefaultsEnum[.codableEnumArray][0], .oneHour)
		XCTAssertEqual(DefaultsEnum[.codableEnumArray][1], .halfHour)
	}

	func testDictionaryType() {
		XCTAssertEqual(DefaultsEnum[.codableEnumDictionary]["0"], .oneHour)
		DefaultsEnum[.codableEnumDictionary]["1"] = .halfHour
		XCTAssertEqual(DefaultsEnum[.codableEnumDictionary]["0"], .oneHour)
		XCTAssertEqual(DefaultsEnum[.codableEnumDictionary]["1"], .halfHour)
	}

	func testFixtureCodableEnumPreferRawRepresentable() {
		let fixture: FixtureCodableEnumPreferRawRepresentable = .tenMinutes
		let keyName = "testFixtureCodableEnumPreferRawRepresentable"
		_ = DefaultsEnum.Key<FixtureCodableEnumPreferRawRepresentable>(keyName, default: fixture)
		XCTAssertNotNil(UserDefaults.standard.integer(forKey: keyName))
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<FixtureCodableEnum>("observeCodableEnumKeyCombine", default: .tenMinutes)
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(FixtureCodableEnum, FixtureCodableEnum)] = [(.tenMinutes, .oneHour), (.oneHour, .tenMinutes)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = .oneHour
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<FixtureCodableEnum?>("observeCodableEnumOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(FixtureCodableEnum?, FixtureCodableEnum?)] = [(nil, .tenMinutes), (.tenMinutes, .halfHour), (.halfHour, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = .tenMinutes
		DefaultsEnum[key] = .halfHour
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[FixtureCodableEnum]>("observeCodableEnumArrayKeyCombine", default: [.tenMinutes])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(FixtureCodableEnum?, FixtureCodableEnum?)] = [(.tenMinutes, .halfHour), (.halfHour, .tenMinutes)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0])
				XCTAssertEqual(expected.1, tuples[index].1[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0] = .halfHour
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: FixtureCodableEnum]>("observeCodableEnumDictionaryKeyCombine", default: ["0": .tenMinutes])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(FixtureCodableEnum?, FixtureCodableEnum?)] = [(.tenMinutes, .halfHour), (.halfHour, .tenMinutes)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"])
				XCTAssertEqual(expected.1, tuples[index].1["0"])
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = .halfHour
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<FixtureCodableEnum>("observeCodableEnumKey", default: .tenMinutes)
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
		let key = DefaultsEnum.Key<FixtureCodableEnum?>("observeCodableEnumOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue, .halfHour)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = .halfHour
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[FixtureCodableEnum]>("observeCodableEnumArrayKey", default: [.tenMinutes])
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
		let key = DefaultsEnum.Key<[String: FixtureCodableEnum]>("observeCodableEnumDictionaryKey", default: ["0": .tenMinutes])
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
