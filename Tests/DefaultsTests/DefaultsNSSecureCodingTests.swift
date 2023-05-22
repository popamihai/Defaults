import Foundation
import CoreData
import Defaults
import XCTest

@objc(ExamplePersistentHistory)
private final class ExamplePersistentHistory: NSPersistentHistoryToken, DefaultsEnum.Serializable {
	let value: String

	init(value: String) {
		self.value = value
		super.init()
	}

	required init?(coder: NSCoder) {
		self.value = coder.decodeObject(forKey: "value") as! String
		super.init()
	}

	override func encode(with coder: NSCoder) {
		coder.encode(value, forKey: "value")
	}

	override class var supportsSecureCoding: Bool { true }
}

// NSSecureCoding
private let persistentHistoryValue = ExamplePersistentHistory(value: "ExampleToken")

extension DefaultsEnum.Keys {
	fileprivate static let persistentHistory = Key<ExamplePersistentHistory>("persistentHistory", default: persistentHistoryValue)
	fileprivate static let persistentHistoryArray = Key<[ExamplePersistentHistory]>("array_persistentHistory", default: [persistentHistoryValue])
	fileprivate static let persistentHistoryDictionary = Key<[String: ExamplePersistentHistory]>("dictionary_persistentHistory", default: ["0": persistentHistoryValue])
}

final class DefaultsNSSecureCodingTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory>("independentNSSecureCodingKey", default: persistentHistoryValue)
		XCTAssertEqual(DefaultsEnum[key].value, persistentHistoryValue.value)
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		DefaultsEnum[key] = newPersistentHistory
		XCTAssertEqual(DefaultsEnum[key].value, newPersistentHistory.value)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory?>("independentNSSecureCodingOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = persistentHistoryValue
		XCTAssertEqual(DefaultsEnum[key]?.value, persistentHistoryValue.value)
		DefaultsEnum[key] = nil
		XCTAssertNil(DefaultsEnum[key])
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		DefaultsEnum[key] = newPersistentHistory
		XCTAssertEqual(DefaultsEnum[key]?.value, newPersistentHistory.value)
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[ExamplePersistentHistory]>("independentNSSecureCodingArrayKey", default: [persistentHistoryValue])
		XCTAssertEqual(DefaultsEnum[key][0].value, persistentHistoryValue.value)
		let newPersistentHistory1 = ExamplePersistentHistory(value: "NewValue1")
		DefaultsEnum[key].append(newPersistentHistory1)
		XCTAssertEqual(DefaultsEnum[key][1].value, newPersistentHistory1.value)
		let newPersistentHistory2 = ExamplePersistentHistory(value: "NewValue2")
		DefaultsEnum[key][1] = newPersistentHistory2
		XCTAssertEqual(DefaultsEnum[key][1].value, newPersistentHistory2.value)
		XCTAssertEqual(DefaultsEnum[key][0].value, persistentHistoryValue.value)
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[ExamplePersistentHistory]?>("independentNSSecureCodingArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [persistentHistoryValue]
		XCTAssertEqual(DefaultsEnum[key]?[0].value, persistentHistoryValue.value)
		DefaultsEnum[key] = nil
		XCTAssertNil(DefaultsEnum[key])
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[ExamplePersistentHistory]]>("independentNSSecureCodingNestedArrayKey", default: [[persistentHistoryValue]])
		XCTAssertEqual(DefaultsEnum[key][0][0].value, persistentHistoryValue.value)
		let newPersistentHistory1 = ExamplePersistentHistory(value: "NewValue1")
		DefaultsEnum[key][0].append(newPersistentHistory1)
		let newPersistentHistory2 = ExamplePersistentHistory(value: "NewValue2")
		DefaultsEnum[key].append([newPersistentHistory2])
		XCTAssertEqual(DefaultsEnum[key][0][1].value, newPersistentHistory1.value)
		XCTAssertEqual(DefaultsEnum[key][1][0].value, newPersistentHistory2.value)
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: ExamplePersistentHistory]]>("independentNSSecureCodingArrayDictionaryKey", default: [["0": persistentHistoryValue]])
		XCTAssertEqual(DefaultsEnum[key][0]["0"]?.value, persistentHistoryValue.value)
		let newPersistentHistory1 = ExamplePersistentHistory(value: "NewValue1")
		DefaultsEnum[key][0]["1"] = newPersistentHistory1
		let newPersistentHistory2 = ExamplePersistentHistory(value: "NewValue2")
		DefaultsEnum[key].append(["0": newPersistentHistory2])
		XCTAssertEqual(DefaultsEnum[key][0]["1"]?.value, newPersistentHistory1.value)
		XCTAssertEqual(DefaultsEnum[key][1]["0"]?.value, newPersistentHistory2.value)
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: ExamplePersistentHistory]>("independentNSSecureCodingDictionaryKey", default: ["0": persistentHistoryValue])
		XCTAssertEqual(DefaultsEnum[key]["0"]?.value, persistentHistoryValue.value)
		let newPersistentHistory1 = ExamplePersistentHistory(value: "NewValue1")
		DefaultsEnum[key]["1"] = newPersistentHistory1
		XCTAssertEqual(DefaultsEnum[key]["1"]?.value, newPersistentHistory1.value)
		let newPersistentHistory2 = ExamplePersistentHistory(value: "NewValue2")
		DefaultsEnum[key]["1"] = newPersistentHistory2
		XCTAssertEqual(DefaultsEnum[key]["1"]?.value, newPersistentHistory2.value)
		XCTAssertEqual(DefaultsEnum[key]["0"]?.value, persistentHistoryValue.value)
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: ExamplePersistentHistory]?>("independentNSSecureCodingDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": persistentHistoryValue]
		XCTAssertEqual(DefaultsEnum[key]?["0"]?.value, persistentHistoryValue.value)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [ExamplePersistentHistory]]>("independentNSSecureCodingDictionaryArrayKey", default: ["0": [persistentHistoryValue]])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0].value, persistentHistoryValue.value)
		let newPersistentHistory1 = ExamplePersistentHistory(value: "NewValue1")
		DefaultsEnum[key]["0"]?.append(newPersistentHistory1)
		let newPersistentHistory2 = ExamplePersistentHistory(value: "NewValue2")
		DefaultsEnum[key]["1"] = [newPersistentHistory2]
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1].value, newPersistentHistory1.value)
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0].value, newPersistentHistory2.value)
	}

	func testType() {
		XCTAssertEqual(DefaultsEnum[.persistentHistory].value, persistentHistoryValue.value)
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		DefaultsEnum[.persistentHistory] = newPersistentHistory
		XCTAssertEqual(DefaultsEnum[.persistentHistory].value, newPersistentHistory.value)
	}

	func testArrayType() {
		XCTAssertEqual(DefaultsEnum[.persistentHistoryArray][0].value, persistentHistoryValue.value)
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		DefaultsEnum[.persistentHistoryArray][0] = newPersistentHistory
		XCTAssertEqual(DefaultsEnum[.persistentHistoryArray][0].value, newPersistentHistory.value)
	}

	func testDictionaryType() {
		XCTAssertEqual(DefaultsEnum[.persistentHistoryDictionary]["0"]?.value, persistentHistoryValue.value)
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		DefaultsEnum[.persistentHistoryDictionary]["0"] = newPersistentHistory
		XCTAssertEqual(DefaultsEnum[.persistentHistoryDictionary]["0"]?.value, newPersistentHistory.value)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory>("observeNSSecureCodingKeyCombine", default: persistentHistoryValue)
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue.value, $0.newValue.value) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(persistentHistoryValue.value, newPersistentHistory.value), (newPersistentHistory.value, persistentHistoryValue.value)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = newPersistentHistory
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory?>("observeNSSecureCodingOptionalKeyCombine")
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue?.value, $0.newValue?.value) }
			.collect(3)

		let expectedValue: [(ExamplePersistentHistory?, ExamplePersistentHistory?)] = [(nil, persistentHistoryValue), (persistentHistoryValue, newPersistentHistory), (newPersistentHistory, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0?.value, tuples[index].0)
				XCTAssertEqual(expected.1?.value, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = persistentHistoryValue
		DefaultsEnum[key] = newPersistentHistory
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[ExamplePersistentHistory]>("observeNSSecureCodingArrayKeyCombine", default: [persistentHistoryValue])
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(ExamplePersistentHistory, ExamplePersistentHistory)] = [(persistentHistoryValue, newPersistentHistory), (newPersistentHistory, persistentHistoryValue)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0.value, tuples[index].0[0].value)
				XCTAssertEqual(expected.1.value, tuples[index].1[0].value)
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0] = newPersistentHistory
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: ExamplePersistentHistory]>("observeNSSecureCodingDictionaryKeyCombine", default: ["0": persistentHistoryValue])
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(ExamplePersistentHistory, ExamplePersistentHistory)] = [(persistentHistoryValue, newPersistentHistory), (newPersistentHistory, persistentHistoryValue)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0.value, tuples[index].0["0"]?.value)
				XCTAssertEqual(expected.1.value, tuples[index].1["0"]?.value)
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = newPersistentHistory
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveMultipleNSSecureKeysCombine() {
		let key1 = DefaultsEnum.Key<ExamplePersistentHistory>("observeMultipleNSSecureCodingKey1", default: ExamplePersistentHistory(value: "TestValue"))
		let key2 = DefaultsEnum.Key<ExamplePersistentHistory>("observeMultipleNSSecureCodingKey2", default: ExamplePersistentHistory(value: "TestValue"))
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum.publisher(keys: key1, key2, options: []).collect(2)

		let cancellable = publisher.sink { _ in
			expect.fulfill()
		}

		DefaultsEnum[key1] = ExamplePersistentHistory(value: "NewTestValue1")
		DefaultsEnum[key2] = ExamplePersistentHistory(value: "NewTestValue2")
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveMultipleNSSecureOptionalKeysCombine() {
		let key1 = DefaultsEnum.Key<ExamplePersistentHistory?>("observeMultipleNSSecureCodingOptionalKey1")
		let key2 = DefaultsEnum.Key<ExamplePersistentHistory?>("observeMultipleNSSecureCodingOptionalKeyKey2")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum.publisher(keys: key1, key2, options: []).collect(2)

		let cancellable = publisher.sink { _ in
			expect.fulfill()
		}

		DefaultsEnum[key1] = ExamplePersistentHistory(value: "NewTestValue1")
		DefaultsEnum[key2] = ExamplePersistentHistory(value: "NewTestValue2")
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveMultipleNSSecureKeys() {
		let key1 = DefaultsEnum.Key<ExamplePersistentHistory>("observeNSSecureCodingKey1", default: ExamplePersistentHistory(value: "TestValue"))
		let key2 = DefaultsEnum.Key<ExamplePersistentHistory>("observeNSSecureCodingKey2", default: ExamplePersistentHistory(value: "TestValue"))
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		var counter = 0
		observation = DefaultsEnum.observe(keys: key1, key2, options: []) {
			counter += 1
			if counter == 2 {
				expect.fulfill()
			} else if counter > 2 {
				XCTFail()
			}
		}

		DefaultsEnum[key1] = ExamplePersistentHistory(value: "NewTestValue1")
		DefaultsEnum[key2] = ExamplePersistentHistory(value: "NewTestValue2")
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testRemoveDuplicatesObserveNSSecureCodingKeyCombine() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory>("observeNSSecureCodingKey", default: ExamplePersistentHistory(value: "TestValue"))
		let expect = expectation(description: "Observation closure being called")

		let inputArray = ["NewTestValue", "NewTestValue", "NewTestValue", "NewTestValue2", "NewTestValue2", "NewTestValue2", "NewTestValue3", "NewTestValue3"]
		let expectedArray = ["NewTestValue", "NewTestValue2", "NewTestValue3"]

		let cancellable = DefaultsEnum
			.publisher(key, options: [])
			.removeDuplicates()
			.map(\.newValue.value)
			.collect(expectedArray.count)
			.sink { result in
				print("Result array: \(result)")

				if result == expectedArray {
					expect.fulfill()
				} else {
					XCTFail("Expected Array is not matched")
				}
			}

		inputArray.forEach {
			DefaultsEnum[key] = ExamplePersistentHistory(value: $0)
		}

		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testRemoveDuplicatesObserveNSSecureCodingOptionalKeyCombine() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory?>("observeNSSecureCodingOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		let inputArray = ["NewTestValue", "NewTestValue", "NewTestValue", "NewTestValue2", "NewTestValue2", "NewTestValue2", "NewTestValue3", "NewTestValue3"]
		let expectedArray = ["NewTestValue", "NewTestValue2", "NewTestValue3", nil]

		let cancellable = DefaultsEnum
			.publisher(key, options: [])
			.removeDuplicates()
			.map(\.newValue)
			.map { $0?.value }
			.collect(expectedArray.count)
			.sink { result in
				print("Result array: \(result)")

				if result == expectedArray {
					expect.fulfill()
				} else {
					XCTFail("Expected Array is not matched")
				}
			}

		inputArray.forEach {
			DefaultsEnum[key] = ExamplePersistentHistory(value: $0)
		}

		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory>("observeNSSecureCodingKey", default: persistentHistoryValue)
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue.value, persistentHistoryValue.value)
			XCTAssertEqual(change.newValue.value, newPersistentHistory.value)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = newPersistentHistory
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<ExamplePersistentHistory?>("observeNSSecureCodingOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue?.value, persistentHistoryValue.value)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = persistentHistoryValue
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[ExamplePersistentHistory]>("observeNSSecureCodingArrayKey", default: [persistentHistoryValue])
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0].value, persistentHistoryValue.value)
			XCTAssertEqual(change.newValue.map(\.value), [persistentHistoryValue, newPersistentHistory].map(\.value))
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key].append(newPersistentHistory)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKey() {
		let key = DefaultsEnum.Key<[String: ExamplePersistentHistory]>("observeNSSecureCodingDictionaryKey", default: ["0": persistentHistoryValue])
		let newPersistentHistory = ExamplePersistentHistory(value: "NewValue")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue["0"]?.value, persistentHistoryValue.value)
			XCTAssertEqual(change.newValue["0"]?.value, persistentHistoryValue.value)
			XCTAssertEqual(change.newValue["1"]?.value, newPersistentHistory.value)

			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["1"] = newPersistentHistory
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
