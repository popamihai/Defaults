import Defaults
import Foundation
import XCTest

private enum mime: String, DefaultsEnum.Serializable {
	case JSON = "application/json"
	case STREAM = "application/octet-stream"
}

private struct CodableUnicorn: DefaultsEnum.Serializable, Codable {
	let is_missing: Bool
}

private struct Unicorn: DefaultsEnum.Serializable, Hashable {
	static let bridge = UnicornBridge()
	let is_missing: Bool
}

private struct UnicornBridge: DefaultsEnum.Bridge {
	typealias Value = Unicorn
	typealias Serializable = Bool

	func serialize(_ value: Value?) -> Serializable? {
		value?.is_missing
	}

	func deserialize(_ object: Serializable?) -> Value? {
		Value(is_missing: object!)
	}
}

extension DefaultsEnum.Keys {
	fileprivate static let magic = Key<[String: DefaultsEnum.AnySerializable]>("magic", default: [:])
	fileprivate static let anyKey = Key<DefaultsEnum.AnySerializable>("anyKey", default: "🦄")
	fileprivate static let anyArrayKey = Key<[DefaultsEnum.AnySerializable]>("anyArrayKey", default: ["No.1 🦄", "No.2 🦄"])
	fileprivate static let anyDictionaryKey = Key<[String: DefaultsEnum.AnySerializable]>("anyDictionaryKey", default: ["unicorn": "🦄"])
}

final class DefaultsAnySerializableTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testReadMeExample() {
		let any = DefaultsEnum.Key<DefaultsEnum.AnySerializable>("anyKey", default: DefaultsEnum.AnySerializable(mime.JSON))
		if let mimeType: mime = DefaultsEnum[any].get() {
			XCTAssertEqual(mimeType, mime.JSON)
		}
		DefaultsEnum[any].set(mime.STREAM)
		if let mimeType: mime = DefaultsEnum[any].get() {
			XCTAssertEqual(mimeType, mime.STREAM)
		}
		DefaultsEnum[any].set(mime.JSON)
		if let mimeType: mime = DefaultsEnum[any].get() {
			XCTAssertEqual(mimeType, mime.JSON)
		}
		DefaultsEnum[.magic]["unicorn"] = "🦄"
		DefaultsEnum[.magic]["number"] = 3
		DefaultsEnum[.magic]["boolean"] = true
		DefaultsEnum[.magic]["enum"] = DefaultsEnum.AnySerializable(mime.JSON)
		XCTAssertEqual(DefaultsEnum[.magic]["unicorn"], "🦄")
		XCTAssertEqual(DefaultsEnum[.magic]["number"], 3)
		if let bool: Bool = DefaultsEnum[.magic]["unicorn"]?.get() {
			XCTAssertTrue(bool)
		}
		XCTAssertEqual(DefaultsEnum[.magic]["enum"]?.get(), mime.JSON)
		DefaultsEnum[.magic]["enum"]?.set(mime.STREAM)
		if let value: String = DefaultsEnum[.magic]["unicorn"]?.get() {
			XCTAssertEqual(value, "🦄")
		}
		if let mimeType: mime = DefaultsEnum[.magic]["enum"]?.get() {
			XCTAssertEqual(mimeType, mime.STREAM)
		}
		DefaultsEnum[any].set(mime.JSON)
		if let mimeType: mime = DefaultsEnum[any].get() {
			XCTAssertEqual(mime.JSON, mimeType)
		}
		DefaultsEnum[any].set(mime.STREAM)
		if let mimeType: mime = DefaultsEnum[any].get() {
			XCTAssertEqual(mime.STREAM, mimeType)
		}
	}

	func testKey() {
		// Test Int
		let any = DefaultsEnum.Key<DefaultsEnum.AnySerializable>("independentAnyKey", default: 121_314)
		XCTAssertEqual(DefaultsEnum[any], 121_314)
		// Test Int8
		let int8 = Int8.max
		DefaultsEnum[any].set(int8)
		XCTAssertEqual(DefaultsEnum[any].get(), int8)
		// Test Int16
		let int16 = Int16.max
		DefaultsEnum[any].set(int16)
		XCTAssertEqual(DefaultsEnum[any].get(), int16)
		// Test Int32
		let int32 = Int32.max
		DefaultsEnum[any].set(int32)
		XCTAssertEqual(DefaultsEnum[any].get(), int32)
		// Test Int64
		let int64 = Int64.max
		DefaultsEnum[any].set(int64)
		XCTAssertEqual(DefaultsEnum[any].get(), int64)
		// Test UInt
		let uint = UInt.max
		DefaultsEnum[any].set(uint)
		XCTAssertEqual(DefaultsEnum[any].get(), uint)
		// Test UInt8
		let uint8 = UInt8.max
		DefaultsEnum[any].set(uint8)
		XCTAssertEqual(DefaultsEnum[any].get(), uint8)
		// Test UInt16
		let uint16 = UInt16.max
		DefaultsEnum[any].set(uint16)
		XCTAssertEqual(DefaultsEnum[any].get(), uint16)
		// Test UInt32
		let uint32 = UInt32.max
		DefaultsEnum[any].set(uint32)
		XCTAssertEqual(DefaultsEnum[any].get(), uint32)
		// Test UInt64
		let uint64 = UInt64.max
		DefaultsEnum[any].set(uint64)
		XCTAssertEqual(DefaultsEnum[any].get(), uint64)
		// Test Double
		DefaultsEnum[any] = 12_131.4
		XCTAssertEqual(DefaultsEnum[any], 12_131.4)
		// Test Bool
		DefaultsEnum[any] = true
		XCTAssertTrue(DefaultsEnum[any].get(Bool.self)!)
		// Test String
		DefaultsEnum[any] = "121314"
		XCTAssertEqual(DefaultsEnum[any], "121314")
		// Test Float
		DefaultsEnum[any].set(12_131.456, type: Float.self)
		XCTAssertEqual(DefaultsEnum[any].get(Float.self), 12_131.456)
		// Test Date
		let date = Date()
		DefaultsEnum[any].set(date)
		XCTAssertEqual(DefaultsEnum[any].get(Date.self), date)
		// Test Data
		let data = "121314".data(using: .utf8)
		DefaultsEnum[any].set(data)
		XCTAssertEqual(DefaultsEnum[any].get(Data.self), data)
		// Test Array
		DefaultsEnum[any] = [1, 2, 3]
		if let array: [Int] = DefaultsEnum[any].get() {
			XCTAssertEqual(array[0], 1)
			XCTAssertEqual(array[1], 2)
			XCTAssertEqual(array[2], 3)
		}
		// Test Dictionary
		DefaultsEnum[any] = ["unicorn": "🦄", "boolean": true, "number": 3]
		if let dictionary = DefaultsEnum[any].get([String: DefaultsEnum.AnySerializable].self) {
			XCTAssertEqual(dictionary["unicorn"], "🦄")
			XCTAssertTrue(dictionary["boolean"]!.get(Bool.self)!)
			XCTAssertEqual(dictionary["number"], 3)
		}
		// Test Set
		DefaultsEnum[any].set(Set([1]))
		XCTAssertEqual(DefaultsEnum[any].get(Set<Int>.self)?.first, 1)
		// Test URL
		DefaultsEnum[any].set(URL(string: "https://example.com")!)
		XCTAssertEqual(DefaultsEnum[any].get()!, URL(string: "https://example.com")!)
		#if os(macOS)
		// Test NSColor
		DefaultsEnum[any].set(NSColor(red: CGFloat(103) / CGFloat(0xFF), green: CGFloat(132) / CGFloat(0xFF), blue: CGFloat(255) / CGFloat(0xFF), alpha: 0.987))
		XCTAssertEqual(DefaultsEnum[any].get(NSColor.self)?.alphaComponent, 0.987)
		#else
		// Test UIColor
		DefaultsEnum[any].set(UIColor(red: CGFloat(103) / CGFloat(0xFF), green: CGFloat(132) / CGFloat(0xFF), blue: CGFloat(255) / CGFloat(0xFF), alpha: 0.654))
		XCTAssertEqual(DefaultsEnum[any].get(UIColor.self)?.cgColor.alpha, 0.654)
		#endif
		// Test Codable type
		DefaultsEnum[any].set(CodableUnicorn(is_missing: false))
		XCTAssertFalse(DefaultsEnum[any].get(CodableUnicorn.self)!.is_missing)
		// Test Custom type
		DefaultsEnum[any].set(Unicorn(is_missing: true))
		XCTAssertTrue(DefaultsEnum[any].get(Unicorn.self)!.is_missing)
		// Test nil
		DefaultsEnum[any] = nil
		XCTAssertEqual(DefaultsEnum[any], 121_314)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<DefaultsEnum.AnySerializable?>("independentOptionalAnyKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = 12_131.4
		XCTAssertEqual(DefaultsEnum[key], 12_131.4)
		DefaultsEnum[key]?.set(mime.JSON)
		XCTAssertEqual(DefaultsEnum[key]?.get(mime.self), mime.JSON)
		DefaultsEnum[key] = nil
		XCTAssertNil(DefaultsEnum[key])
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[DefaultsEnum.AnySerializable]>("independentArrayAnyKey", default: [123, 456])
		XCTAssertEqual(DefaultsEnum[key][0], 123)
		XCTAssertEqual(DefaultsEnum[key][1], 456)
		DefaultsEnum[key][0] = 12_131.4
		XCTAssertEqual(DefaultsEnum[key][0], 12_131.4)
	}

	func testSetKey() {
		let key = DefaultsEnum.Key<Set<DefaultsEnum.AnySerializable>>("independentArrayAnyKey", default: [123])
		XCTAssertEqual(DefaultsEnum[key].first, 123)
		DefaultsEnum[key].insert(12_131.4)
		XCTAssertTrue(DefaultsEnum[key].contains(12_131.4))
		let date = DefaultsEnum.AnySerializable(Date())
		DefaultsEnum[key].insert(date)
		XCTAssertTrue(DefaultsEnum[key].contains(date))
		let data = DefaultsEnum.AnySerializable("Hello World!".data(using: .utf8))
		DefaultsEnum[key].insert(data)
		XCTAssertTrue(DefaultsEnum[key].contains(data))
		let int = DefaultsEnum.AnySerializable(Int.max)
		DefaultsEnum[key].insert(int)
		XCTAssertTrue(DefaultsEnum[key].contains(int))
		let int8 = DefaultsEnum.AnySerializable(Int8.max)
		DefaultsEnum[key].insert(int8)
		XCTAssertTrue(DefaultsEnum[key].contains(int8))
		let int16 = DefaultsEnum.AnySerializable(Int16.max)
		DefaultsEnum[key].insert(int16)
		XCTAssertTrue(DefaultsEnum[key].contains(int16))
		let int32 = DefaultsEnum.AnySerializable(Int32.max)
		DefaultsEnum[key].insert(int32)
		XCTAssertTrue(DefaultsEnum[key].contains(int32))
		let int64 = DefaultsEnum.AnySerializable(Int64.max)
		DefaultsEnum[key].insert(int64)
		XCTAssertTrue(DefaultsEnum[key].contains(int64))
		let uint = DefaultsEnum.AnySerializable(UInt.max)
		DefaultsEnum[key].insert(uint)
		XCTAssertTrue(DefaultsEnum[key].contains(uint))
		let uint8 = DefaultsEnum.AnySerializable(UInt8.max)
		DefaultsEnum[key].insert(uint8)
		XCTAssertTrue(DefaultsEnum[key].contains(uint8))
		let uint16 = DefaultsEnum.AnySerializable(UInt16.max)
		DefaultsEnum[key].insert(uint16)
		XCTAssertTrue(DefaultsEnum[key].contains(uint16))
		let uint32 = DefaultsEnum.AnySerializable(UInt32.max)
		DefaultsEnum[key].insert(uint32)
		XCTAssertTrue(DefaultsEnum[key].contains(uint32))
		let uint64 = DefaultsEnum.AnySerializable(UInt64.max)
		DefaultsEnum[key].insert(uint64)
		XCTAssertTrue(DefaultsEnum[key].contains(uint64))

		let bool: DefaultsEnum.AnySerializable = false
		DefaultsEnum[key].insert(bool)
		XCTAssertTrue(DefaultsEnum[key].contains(bool))

		let float = DefaultsEnum.AnySerializable(Float(1213.14))
		DefaultsEnum[key].insert(float)
		XCTAssertTrue(DefaultsEnum[key].contains(float))

		let cgFloat = DefaultsEnum.AnySerializable(CGFloat(12_131.415))
		DefaultsEnum[key].insert(cgFloat)
		XCTAssertTrue(DefaultsEnum[key].contains(cgFloat))

		let string = DefaultsEnum.AnySerializable("Hello World!")
		DefaultsEnum[key].insert(string)
		XCTAssertTrue(DefaultsEnum[key].contains(string))

		let array: DefaultsEnum.AnySerializable = [1, 2, 3, 4]
		DefaultsEnum[key].insert(array)
		XCTAssertTrue(DefaultsEnum[key].contains(array))

		let dictionary: DefaultsEnum.AnySerializable = ["Hello": "World!"]
		DefaultsEnum[key].insert(dictionary)
		XCTAssertTrue(DefaultsEnum[key].contains(dictionary))

		let unicorn = DefaultsEnum.AnySerializable(Unicorn(is_missing: true))
		DefaultsEnum[key].insert(unicorn)
		XCTAssertTrue(DefaultsEnum[key].contains(unicorn))
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[DefaultsEnum.AnySerializable]?>("testArrayOptionalAnyKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [123]
		DefaultsEnum[key]?.append(456)
		XCTAssertEqual(DefaultsEnum[key]![0], 123)
		XCTAssertEqual(DefaultsEnum[key]![1], 456)
		DefaultsEnum[key]![0] = 12_131.4
		XCTAssertEqual(DefaultsEnum[key]![0], 12_131.4)
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[DefaultsEnum.AnySerializable]]>("testNestedArrayAnyKey", default: [[123]])
		DefaultsEnum[key][0].append(456)
		XCTAssertEqual(DefaultsEnum[key][0][0], 123)
		XCTAssertEqual(DefaultsEnum[key][0][1], 456)
		DefaultsEnum[key].append([12_131.4])
		XCTAssertEqual(DefaultsEnum[key][1][0], 12_131.4)
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: DefaultsEnum.AnySerializable]>("independentDictionaryAnyKey", default: ["unicorn": ""])
		XCTAssertEqual(DefaultsEnum[key]["unicorn"], "")
		DefaultsEnum[key]["unicorn"] = "🦄"
		XCTAssertEqual(DefaultsEnum[key]["unicorn"], "🦄")
		DefaultsEnum[key]["number"] = 3
		DefaultsEnum[key]["boolean"] = true
		XCTAssertEqual(DefaultsEnum[key]["number"], 3)
		if let bool: Bool = DefaultsEnum[.magic]["unicorn"]?.get() {
			XCTAssertTrue(bool)
		}
		DefaultsEnum[key]["set"] = DefaultsEnum.AnySerializable(Set([1]))
		XCTAssertEqual(DefaultsEnum[key]["set"]!.get(Set<Int>.self)!.first, 1)
		DefaultsEnum[key]["nil"] = nil
		XCTAssertNil(DefaultsEnum[key]["nil"])
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: DefaultsEnum.AnySerializable]?>("independentDictionaryOptionalAnyKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["unicorn": "🦄"]
		XCTAssertEqual(DefaultsEnum[key]?["unicorn"], "🦄")
		DefaultsEnum[key]?["number"] = 3
		DefaultsEnum[key]?["boolean"] = true
		XCTAssertEqual(DefaultsEnum[key]?["number"], 3)
		XCTAssertEqual(DefaultsEnum[key]?["boolean"], true)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [DefaultsEnum.AnySerializable]]>("independentDictionaryArrayAnyKey", default: ["number": [1]])
		XCTAssertEqual(DefaultsEnum[key]["number"]?[0], 1)
		DefaultsEnum[key]["number"]?.append(2)
		DefaultsEnum[key]["unicorn"] = ["No.1 🦄"]
		DefaultsEnum[key]["unicorn"]?.append("No.2 🦄")
		DefaultsEnum[key]["unicorn"]?.append("No.3 🦄")
		DefaultsEnum[key]["boolean"] = [true]
		DefaultsEnum[key]["boolean"]?.append(false)
		XCTAssertEqual(DefaultsEnum[key]["number"]?[1], 2)
		XCTAssertEqual(DefaultsEnum[key]["unicorn"]?[0], "No.1 🦄")
		XCTAssertEqual(DefaultsEnum[key]["unicorn"]?[1], "No.2 🦄")
		XCTAssertEqual(DefaultsEnum[key]["unicorn"]?[2], "No.3 🦄")
		XCTAssertTrue(DefaultsEnum[key]["boolean"]![0].get(Bool.self)!)
		XCTAssertFalse(DefaultsEnum[key]["boolean"]![1].get(Bool.self)!)
	}

	func testType() {
		XCTAssertEqual(DefaultsEnum[.anyKey], "🦄")
		DefaultsEnum[.anyKey] = 123
		XCTAssertEqual(DefaultsEnum[.anyKey], 123)
	}

	func testArrayType() {
		XCTAssertEqual(DefaultsEnum[.anyArrayKey][0], "No.1 🦄")
		XCTAssertEqual(DefaultsEnum[.anyArrayKey][1], "No.2 🦄")
		DefaultsEnum[.anyArrayKey].append(123)
		XCTAssertEqual(DefaultsEnum[.anyArrayKey][2], 123)
	}

	func testDictionaryType() {
		XCTAssertEqual(DefaultsEnum[.anyDictionaryKey]["unicorn"], "🦄")
		DefaultsEnum[.anyDictionaryKey]["number"] = 3
		XCTAssertEqual(DefaultsEnum[.anyDictionaryKey]["number"], 3)
		DefaultsEnum[.anyDictionaryKey]["boolean"] = true
		XCTAssertTrue(DefaultsEnum[.anyDictionaryKey]["boolean"]!.get(Bool.self)!)
		DefaultsEnum[.anyDictionaryKey]["array"] = [1, 2]
		if let array = DefaultsEnum[.anyDictionaryKey]["array"]?.get([Int].self) {
			XCTAssertEqual(array[0], 1)
			XCTAssertEqual(array[1], 2)
		}
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<DefaultsEnum.AnySerializable>("observeAnyKeyCombine", default: 123)
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(DefaultsEnum.AnySerializable, DefaultsEnum.AnySerializable)] = [(123, "🦄"), ("🦄", 123)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = "🦄"
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<DefaultsEnum.AnySerializable?>("observeAnyOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(DefaultsEnum.AnySerializable?, DefaultsEnum.AnySerializable?)] = [(nil, 123), (123, "🦄"), ("🦄", nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				if tuples[index].0?.get(Int.self) != nil {
					XCTAssertEqual(expected.0, tuples[index].0)
					XCTAssertEqual(expected.1, tuples[index].1)
				} else if tuples[index].0?.get(String.self) != nil {
					XCTAssertEqual(expected.0, tuples[index].0)
					XCTAssertNil(tuples[index].1)
				} else {
					XCTAssertNil(tuples[index].0)
					XCTAssertEqual(expected.1, tuples[index].1)
				}
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = 123
		DefaultsEnum[key] = "🦄"
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<DefaultsEnum.AnySerializable>("observeAnyKey", default: 123)
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, 123)
			XCTAssertEqual(change.newValue, "🦄")
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = "🦄"
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<DefaultsEnum.AnySerializable?>("observeAnyOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue, "🦄")
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = "🦄"
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
