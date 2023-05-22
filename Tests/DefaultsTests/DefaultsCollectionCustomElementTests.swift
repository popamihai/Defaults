import Foundation
import XCTest
import Defaults

private struct Item: Equatable {
	let name: String
	let count: UInt
}

extension Item: DefaultsEnum.Serializable {
	static let bridge = ItemBridge()
}

private struct ItemBridge: DefaultsEnum.Bridge {
	typealias Value = Item
	typealias Serializable = [String: String]
	func serialize(_ value: Value?) -> Serializable? {
		guard let value else {
			return nil
		}

		return ["name": value.name, "count": String(value.count)]
	}

	func deserialize(_ object: Serializable?) -> Value? {
		guard
			let object,
			let name = object["name"],
			let count = UInt(object["count"] ?? "0")
		else {
			return nil
		}

		return Value(name: name, count: count)
	}
}

private let fixtureCustomCollection = Item(name: "Apple", count: 10)
private let fixtureCustomCollection1 = Item(name: "Banana", count: 20)
private let fixtureCustomCollection2 = Item(name: "Grape", count: 30)

extension DefaultsEnum.Keys {
	fileprivate static let collectionCustomElement = Key<Bag<Item>>("collectionCustomElement", default: .init(items: [fixtureCustomCollection]))
	fileprivate static let collectionCustomElementArray = Key<[Bag<Item>]>("collectionCustomElementArray", default: [.init(items: [fixtureCustomCollection])])
	fileprivate static let collectionCustomElementDictionary = Key<[String: Bag<Item>]>("collectionCustomElementDictionary", default: ["0": .init(items: [fixtureCustomCollection])])
}

final class DefaultsCollectionCustomElementTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<Bag<Item>>("independentCollectionCustomElementKey", default: .init(items: [fixtureCustomCollection]))
		DefaultsEnum[key].insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[key].insert(element: fixtureCustomCollection2, at: 2)
		XCTAssertEqual(DefaultsEnum[key][0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key][1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key][2], fixtureCustomCollection2)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<Bag<Item>?>("independentCollectionCustomElementOptionalKey")
		DefaultsEnum[key] = .init(items: [fixtureCustomCollection])
		DefaultsEnum[key]?.insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[key]?.insert(element: fixtureCustomCollection2, at: 2)
		XCTAssertEqual(DefaultsEnum[key]?[0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key]?[1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key]?[2], fixtureCustomCollection2)
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[Bag<Item>]>("independentCollectionCustomElementArrayKey", default: [.init(items: [fixtureCustomCollection])])
		DefaultsEnum[key][0].insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[key].append(.init(items: [fixtureCustomCollection2]))
		XCTAssertEqual(DefaultsEnum[key][0][0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key][0][1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key][1][0], fixtureCustomCollection2)
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[Bag<Item>]?>("independentCollectionCustomElementArrayOptionalKey")
		DefaultsEnum[key] = [.init(items: [fixtureCustomCollection])]
		DefaultsEnum[key]?[0].insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[key]?.append(Bag(items: [fixtureCustomCollection2]))
		XCTAssertEqual(DefaultsEnum[key]?[0][0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key]?[0][1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key]?[1][0], fixtureCustomCollection2)
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[Bag<Item>]]>("independentCollectionCustomElementNestedArrayKey", default: [[.init(items: [fixtureCustomCollection])]])
		DefaultsEnum[key][0][0].insert(element: fixtureCustomCollection, at: 1)
		DefaultsEnum[key][0].append(.init(items: [fixtureCustomCollection1]))
		DefaultsEnum[key].append([.init(items: [fixtureCustomCollection2])])
		XCTAssertEqual(DefaultsEnum[key][0][0][0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key][0][0][1], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key][0][1][0], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key][1][0][0], fixtureCustomCollection2)
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: Bag<Item>]]>("independentCollectionCustomElementArrayDictionaryKey", default: [["0": .init(items: [fixtureCustomCollection])]])
		DefaultsEnum[key][0]["0"]?.insert(element: fixtureCustomCollection, at: 1)
		DefaultsEnum[key][0]["1"] = .init(items: [fixtureCustomCollection1])
		DefaultsEnum[key].append(["0": .init(items: [fixtureCustomCollection2])])
		XCTAssertEqual(DefaultsEnum[key][0]["0"]?[0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key][0]["0"]?[1], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key][0]["1"]?[0], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key][1]["0"]?[0], fixtureCustomCollection2)
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: Bag<Item>]>("independentCollectionCustomElementDictionaryKey", default: ["0": .init(items: [fixtureCustomCollection])])
		DefaultsEnum[key]["0"]?.insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[key]["1"] = .init(items: [fixtureCustomCollection2])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0], fixtureCustomCollection2)
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: Bag<Item>]?>("independentCollectionCustomElementDictionaryOptionalKey")
		DefaultsEnum[key] = ["0": .init(items: [fixtureCustomCollection])]
		DefaultsEnum[key]?["0"]?.insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[key]?["1"] = .init(items: [fixtureCustomCollection2])
		XCTAssertEqual(DefaultsEnum[key]?["0"]?[0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key]?["0"]?[1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key]?["1"]?[0], fixtureCustomCollection2)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [Bag<Item>]]>("independentCollectionCustomElementDictionaryArrayKey", default: ["0": [.init(items: [fixtureCustomCollection])]])
		DefaultsEnum[key]["0"]?[0].insert(element: fixtureCustomCollection, at: 1)
		DefaultsEnum[key]["0"]?.append(.init(items: [fixtureCustomCollection1]))
		DefaultsEnum[key]["1"] = [.init(items: [fixtureCustomCollection2])]
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0][0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0][1], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1][0], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0][0], fixtureCustomCollection2)
	}

	func testType() {
		DefaultsEnum[.collectionCustomElement].insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[.collectionCustomElement].insert(element: fixtureCustomCollection2, at: 2)
		XCTAssertEqual(DefaultsEnum[.collectionCustomElement][0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[.collectionCustomElement][1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[.collectionCustomElement][2], fixtureCustomCollection2)
	}

	func testArrayType() {
		DefaultsEnum[.collectionCustomElementArray][0].insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[.collectionCustomElementArray].append(.init(items: [fixtureCustomCollection2]))
		XCTAssertEqual(DefaultsEnum[.collectionCustomElementArray][0][0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[.collectionCustomElementArray][0][1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[.collectionCustomElementArray][1][0], fixtureCustomCollection2)
	}

	func testDictionaryType() {
		DefaultsEnum[.collectionCustomElementDictionary]["0"]?.insert(element: fixtureCustomCollection1, at: 1)
		DefaultsEnum[.collectionCustomElementDictionary]["1"] = .init(items: [fixtureCustomCollection2])
		XCTAssertEqual(DefaultsEnum[.collectionCustomElementDictionary]["0"]?[0], fixtureCustomCollection)
		XCTAssertEqual(DefaultsEnum[.collectionCustomElementDictionary]["0"]?[1], fixtureCustomCollection1)
		XCTAssertEqual(DefaultsEnum[.collectionCustomElementDictionary]["1"]?[0], fixtureCustomCollection2)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<Bag<Item>>("observeCollectionCustomElementKeyCombine", default: .init(items: [fixtureCustomCollection]))
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCustomCollection, fixtureCustomCollection1), (fixtureCustomCollection1, fixtureCustomCollection)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0])
				XCTAssertEqual(expected.1, tuples[index].1[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key].insert(element: fixtureCustomCollection1, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<Bag<Item>?>("observeCollectionCustomElementOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(Item?, Item?)] = [(nil, fixtureCustomCollection), (fixtureCustomCollection, fixtureCustomCollection1), (fixtureCustomCollection1, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0?[0])
				XCTAssertEqual(expected.1, tuples[index].1?[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = .init(items: [fixtureCustomCollection])
		DefaultsEnum[key]?.insert(element: fixtureCustomCollection1, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[Bag<Item>]>("observeCollectionCustomElementArrayKeyCombine", default: [.init(items: [fixtureCustomCollection])])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCustomCollection, fixtureCustomCollection1), (fixtureCustomCollection1, fixtureCustomCollection)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0][0])
				XCTAssertEqual(expected.1, tuples[index].1[0][0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0].insert(element: fixtureCustomCollection1, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: Bag<Item>]>("observeCollectionCustomElementDictionaryKeyCombine", default: ["0": .init(items: [fixtureCustomCollection])])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCustomCollection, fixtureCustomCollection1), (fixtureCustomCollection1, fixtureCustomCollection)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"]?[0])
				XCTAssertEqual(expected.1, tuples[index].1["0"]?[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"]?.insert(element: fixtureCustomCollection1, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<Bag<Item>>("observeCollectionCustomElementKey", default: .init(items: [fixtureCustomCollection]))
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0], fixtureCustomCollection)
			XCTAssertEqual(change.newValue[0], fixtureCustomCollection1)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key].insert(element: fixtureCustomCollection1, at: 0)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<Bag<Item>?>("observeCollectionCustomElementOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue?[0], fixtureCustomCollection)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = .init(items: [fixtureCustomCollection])
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[Bag<Item>]>("observeCollectionCustomElementArrayKey", default: [.init(items: [fixtureCustomCollection])])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0][0], fixtureCustomCollection)
			XCTAssertEqual(change.newValue[0][0], fixtureCustomCollection1)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key][0].insert(element: fixtureCustomCollection1, at: 0)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKey() {
		let key = DefaultsEnum.Key<[String: Bag<Item>]>("observeCollectionCustomElementArrayKey", default: ["0": .init(items: [fixtureCustomCollection])])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue["0"]?[0], fixtureCustomCollection)
			XCTAssertEqual(change.newValue["0"]?[0], fixtureCustomCollection1)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["0"]?.insert(element: fixtureCustomCollection1, at: 0)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
