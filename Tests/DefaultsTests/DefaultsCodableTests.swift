import Foundation
import XCTest
import Defaults

private struct Unicorn: Codable, DefaultsEnum.Serializable {
	var isUnicorn: Bool
}

private let fixtureCodable = Unicorn(isUnicorn: true)

@objc(UnicornCodableAndNSSecureCoding)
private final class UnicornCodableAndNSSecureCoding: NSObject, NSSecureCoding, Codable, DefaultsEnum.Serializable {
	static let supportsSecureCoding = true

	func encode(with coder: NSCoder) {}

	init?(coder: NSCoder) {}

	override init() {
		super.init()
	}
}

@objc(UnicornCodableAndPreferNSSecureCoding)
private final class UnicornCodableAndPreferNSSecureCoding: NSObject, NSSecureCoding, Codable, DefaultsEnum.Serializable, DefaultsEnum.PreferNSSecureCoding {
	static let supportsSecureCoding = true

	func encode(with coder: NSCoder) {}

	init?(coder: NSCoder) {}

	override init() {
		super.init()
	}
}

extension DefaultsEnum.Keys {
	fileprivate static let codable = Key<Unicorn>("codable", default: fixtureCodable)
	fileprivate static let codableArray = Key<[Unicorn]>("codable", default: [fixtureCodable])
	fileprivate static let codableDictionary = Key<[String: Unicorn]>("codable", default: ["0": fixtureCodable])
}

final class DefaultsCodableTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<Unicorn>("independentCodableKey", default: fixtureCodable)
		XCTAssertTrue(DefaultsEnum[key].isUnicorn)
		DefaultsEnum[key].isUnicorn = false
		XCTAssertFalse(DefaultsEnum[key].isUnicorn)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<Unicorn?>("independentCodableOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = Unicorn(isUnicorn: true)
		XCTAssertTrue(DefaultsEnum[key]?.isUnicorn ?? false)
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[Unicorn]>("independentCodableArrayKey", default: [fixtureCodable])
		XCTAssertTrue(DefaultsEnum[key][0].isUnicorn)
		DefaultsEnum[key].append(Unicorn(isUnicorn: false))
		XCTAssertTrue(DefaultsEnum[key][0].isUnicorn)
		XCTAssertFalse(DefaultsEnum[key][1].isUnicorn)
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[Unicorn]?>("independentCodableArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [fixtureCodable]
		DefaultsEnum[key]?.append(Unicorn(isUnicorn: false))
		XCTAssertTrue(DefaultsEnum[key]?[0].isUnicorn ?? false)
		XCTAssertFalse(DefaultsEnum[key]?[1].isUnicorn ?? false)
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[Unicorn]]>("independentCodableNestedArrayKey", default: [[fixtureCodable]])
		XCTAssertTrue(DefaultsEnum[key][0][0].isUnicorn)
		DefaultsEnum[key].append([fixtureCodable])
		DefaultsEnum[key][0].append(Unicorn(isUnicorn: false))
		XCTAssertTrue(DefaultsEnum[key][0][0].isUnicorn)
		XCTAssertTrue(DefaultsEnum[key][1][0].isUnicorn)
		XCTAssertFalse(DefaultsEnum[key][0][1].isUnicorn)
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: Unicorn]]>("independentCodableArrayDictionaryKey", default: [["0": fixtureCodable]])
		XCTAssertTrue(DefaultsEnum[key][0]["0"]?.isUnicorn ?? false)
		DefaultsEnum[key].append(["0": fixtureCodable])
		DefaultsEnum[key][0]["1"] = Unicorn(isUnicorn: false)
		XCTAssertTrue(DefaultsEnum[key][0]["0"]?.isUnicorn ?? false)
		XCTAssertTrue(DefaultsEnum[key][1]["0"]?.isUnicorn ?? false)
		XCTAssertFalse(DefaultsEnum[key][0]["1"]?.isUnicorn ?? true)
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: Unicorn]>("independentCodableDictionaryKey", default: ["0": fixtureCodable])
		XCTAssertTrue(DefaultsEnum[key]["0"]?.isUnicorn ?? false)
		DefaultsEnum[key]["1"] = Unicorn(isUnicorn: false)
		XCTAssertTrue(DefaultsEnum[key]["0"]?.isUnicorn ?? false)
		XCTAssertFalse(DefaultsEnum[key]["1"]?.isUnicorn ?? true)
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: Unicorn]?>("independentCodableDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": fixtureCodable]
		DefaultsEnum[key]?["1"] = Unicorn(isUnicorn: false)
		XCTAssertTrue(DefaultsEnum[key]?["0"]?.isUnicorn ?? false)
		XCTAssertFalse(DefaultsEnum[key]?["1"]?.isUnicorn ?? true)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [Unicorn]]>("independentCodableDictionaryArrayKey", default: ["0": [fixtureCodable]])
		XCTAssertTrue(DefaultsEnum[key]["0"]?[0].isUnicorn ?? false)
		DefaultsEnum[key]["1"] = [fixtureCodable]
		DefaultsEnum[key]["0"]?.append(Unicorn(isUnicorn: false))
		XCTAssertTrue(DefaultsEnum[key]["1"]?[0].isUnicorn ?? false)
		XCTAssertFalse(DefaultsEnum[key]["0"]?[1].isUnicorn ?? true)
	}

	func testType() {
		XCTAssertTrue(DefaultsEnum[.codable].isUnicorn)
		DefaultsEnum[.codable] = Unicorn(isUnicorn: false)
		XCTAssertFalse(DefaultsEnum[.codable].isUnicorn)
	}

	func testArrayType() {
		XCTAssertTrue(DefaultsEnum[.codableArray][0].isUnicorn)
		DefaultsEnum[.codableArray][0] = Unicorn(isUnicorn: false)
		XCTAssertFalse(DefaultsEnum[.codableArray][0].isUnicorn)
	}

	func testDictionaryType() {
		XCTAssertTrue(DefaultsEnum[.codableDictionary]["0"]?.isUnicorn ?? false)
		DefaultsEnum[.codableDictionary]["0"] = Unicorn(isUnicorn: false)
		XCTAssertFalse(DefaultsEnum[.codableDictionary]["0"]?.isUnicorn ?? true)
	}

	func testCodableAndNSSecureCoding() {
		let fixture = UnicornCodableAndNSSecureCoding()
		let keyName = "testCodableAndNSSecureCoding"
		_ = DefaultsEnum.Key<UnicornCodableAndNSSecureCoding>(keyName, default: fixture)
		XCTAssertNil(UserDefaults.standard.data(forKey: keyName))
		XCTAssertNotNil(UserDefaults.standard.string(forKey: keyName))
	}

	func testCodableAndPreferNSSecureCoding() {
		let fixture = UnicornCodableAndPreferNSSecureCoding()
		let keyName = "testCodableAndPreferNSSecureCoding"
		_ = DefaultsEnum.Key<UnicornCodableAndPreferNSSecureCoding>(keyName, default: fixture)
		XCTAssertNil(UserDefaults.standard.string(forKey: keyName))
		XCTAssertNotNil(UserDefaults.standard.data(forKey: keyName))
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<Unicorn>("observeCodableKeyCombine", default: fixtureCodable)
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue.isUnicorn, $0.newValue.isUnicorn) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(true, false), (false, true)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = Unicorn(isUnicorn: false)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<Unicorn?>("observeCodableOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue?.isUnicorn, $0.newValue?.isUnicorn) }
			.collect(2)

		let expectedValue: [(Bool?, Bool?)] = [(nil, true), (true, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureCodable
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[Unicorn]>("observeCodableArrayKeyCombine", default: [fixtureCodable])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(true, false), (false, true)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0].isUnicorn)
				XCTAssertEqual(expected.1, tuples[index].1[0].isUnicorn)
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0] = Unicorn(isUnicorn: false)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: Unicorn]>("observeCodableDictionaryKeyCombine", default: ["0": fixtureCodable])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(true, false), (false, true)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"]?.isUnicorn)
				XCTAssertEqual(expected.1, tuples[index].1["0"]?.isUnicorn)
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = Unicorn(isUnicorn: false)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<Unicorn>("observeCodableKey", default: fixtureCodable)
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertTrue(change.oldValue.isUnicorn)
			XCTAssertFalse(change.newValue.isUnicorn)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = Unicorn(isUnicorn: false)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<Unicorn?>("observeCodableOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertTrue(change.newValue?.isUnicorn ?? false)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureCodable
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[Unicorn]>("observeCodableArrayKey", default: [fixtureCodable])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertTrue(change.oldValue[0].isUnicorn)
			XCTAssertFalse(change.newValue[0].isUnicorn)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key][0] = Unicorn(isUnicorn: false)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKey() {
		let key = DefaultsEnum.Key<[String: Unicorn]>("observeCodableDictionaryKey", default: ["0": fixtureCodable])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertTrue(change.oldValue["0"]?.isUnicorn ?? false)
			XCTAssertFalse(change.newValue["0"]?.isUnicorn ?? true)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = Unicorn(isUnicorn: false)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
