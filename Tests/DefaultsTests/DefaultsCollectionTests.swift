import Foundation
import XCTest
import Defaults

struct Bag<Element: DefaultsEnum.Serializable>: Collection {
	var items: [Element]

	init(items: [Element]) {
		self.items = items
	}

	var startIndex: Int {
		items.startIndex
	}

	var endIndex: Int {
		items.endIndex
	}

	mutating func insert(element: Element, at: Int) {
		items.insert(element, at: at)
	}

	func index(after index: Int) -> Int {
		items.index(after: index)
	}

	subscript(position: Int) -> Element {
		items[position]
	}
}

extension Bag: DefaultsEnum.CollectionSerializable {
	init(_ elements: [Element]) {
		self.items = elements
	}
}


private let fixtureCollection = ["Juice", "Apple", "Banana"]

extension DefaultsEnum.Keys {
	fileprivate static let collection = Key<Bag<String>>("collection", default: Bag(items: fixtureCollection))
	fileprivate static let collectionArray = Key<[Bag<String>]>("collectionArray", default: [Bag(items: fixtureCollection)])
	fileprivate static let collectionDictionary = Key<[String: Bag<String>]>("collectionDictionary", default: ["0": Bag(items: fixtureCollection)])
}

final class DefaultsCollectionTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<Bag<String>>("independentCollectionKey", default: Bag(items: fixtureCollection))
		DefaultsEnum[key].insert(element: "123", at: 0)
		XCTAssertEqual(DefaultsEnum[key][0], "123")
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<Bag<String>?>("independentCollectionOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = Bag(items: [])
		DefaultsEnum[key]?.insert(element: fixtureCollection[0], at: 0)
		XCTAssertEqual(DefaultsEnum[key]?[0], fixtureCollection[0])
		DefaultsEnum[key]?.insert(element: fixtureCollection[1], at: 1)
		XCTAssertEqual(DefaultsEnum[key]?[1], fixtureCollection[1])
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[Bag<String>]>("independentCollectionArrayKey", default: [Bag(items: [fixtureCollection[0]])])
		DefaultsEnum[key].append(Bag(items: [fixtureCollection[1]]))
		XCTAssertEqual(DefaultsEnum[key][1][0], fixtureCollection[1])
		DefaultsEnum[key][0].insert(element: fixtureCollection[2], at: 1)
		XCTAssertEqual(DefaultsEnum[key][0][1], fixtureCollection[2])
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[Bag<String>]?>("independentCollectionArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [Bag(items: [fixtureCollection[0]])]
		DefaultsEnum[key]?.append(Bag(items: [fixtureCollection[1]]))
		XCTAssertEqual(DefaultsEnum[key]?[1][0], fixtureCollection[1])
		DefaultsEnum[key]?[0].insert(element: fixtureCollection[2], at: 1)
		XCTAssertEqual(DefaultsEnum[key]?[0][1], fixtureCollection[2])
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[Bag<String>]]>("independentCollectionNestedArrayKey", default: [[Bag(items: [fixtureCollection[0]])]])
		DefaultsEnum[key][0].append(Bag(items: [fixtureCollection[1]]))
		DefaultsEnum[key].append([Bag(items: [fixtureCollection[2]])])
		XCTAssertEqual(DefaultsEnum[key][0][0][0], fixtureCollection[0])
		XCTAssertEqual(DefaultsEnum[key][0][1][0], fixtureCollection[1])
		XCTAssertEqual(DefaultsEnum[key][1][0][0], fixtureCollection[2])
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: Bag<String>]]>("independentCollectionArrayDictionaryKey", default: [["0": Bag(items: [fixtureCollection[0]])]])
		DefaultsEnum[key][0]["1"] = Bag(items: [fixtureCollection[1]])
		DefaultsEnum[key].append(["0": Bag(items: [fixtureCollection[2]])])
		XCTAssertEqual(DefaultsEnum[key][0]["0"]?[0], fixtureCollection[0])
		XCTAssertEqual(DefaultsEnum[key][0]["1"]?[0], fixtureCollection[1])
		XCTAssertEqual(DefaultsEnum[key][1]["0"]?[0], fixtureCollection[2])
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: Bag<String>]>("independentCollectionDictionaryKey", default: ["0": Bag(items: [fixtureCollection[0]])])
		DefaultsEnum[key]["0"]?.insert(element: fixtureCollection[1], at: 1)
		DefaultsEnum[key]["1"] = Bag(items: [fixtureCollection[2]])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], fixtureCollection[0])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1], fixtureCollection[1])
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0], fixtureCollection[2])
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: Bag<String>]?>("independentCollectionDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": Bag(items: [fixtureCollection[0]])]
		DefaultsEnum[key]?["0"]?.insert(element: fixtureCollection[1], at: 1)
		DefaultsEnum[key]?["1"] = Bag(items: [fixtureCollection[2]])
		XCTAssertEqual(DefaultsEnum[key]?["0"]?[0], fixtureCollection[0])
		XCTAssertEqual(DefaultsEnum[key]?["0"]?[1], fixtureCollection[1])
		XCTAssertEqual(DefaultsEnum[key]?["1"]?[0], fixtureCollection[2])
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [Bag<String>]]>("independentCollectionDictionaryArrayKey", default: ["0": [Bag(items: [fixtureCollection[0]])]])
		DefaultsEnum[key]["0"]?[0].insert(element: fixtureCollection[1], at: 1)
		DefaultsEnum[key]["1"] = [Bag(items: [fixtureCollection[2]])]
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0][0], fixtureCollection[0])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0][1], fixtureCollection[1])
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0][0], fixtureCollection[2])
	}

	func testType() {
		DefaultsEnum[.collection].insert(element: "123", at: 0)
		XCTAssertEqual(DefaultsEnum[.collection][0], "123")
	}

	func testArrayType() {
		DefaultsEnum[.collectionArray].append(Bag(items: [fixtureCollection[0]]))
		DefaultsEnum[.collectionArray][0].insert(element: "123", at: 0)
		XCTAssertEqual(DefaultsEnum[.collectionArray][0][0], "123")
		XCTAssertEqual(DefaultsEnum[.collectionArray][1][0], fixtureCollection[0])
	}

	func testDictionaryType() {
		DefaultsEnum[.collectionDictionary]["1"] = Bag(items: [fixtureCollection[0]])
		DefaultsEnum[.collectionDictionary]["0"]?.insert(element: "123", at: 0)
		XCTAssertEqual(DefaultsEnum[.collectionDictionary]["0"]?[0], "123")
		XCTAssertEqual(DefaultsEnum[.collectionDictionary]["1"]?[0], fixtureCollection[0])
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<Bag<String>>("observeCollectionKeyCombine", default: .init(items: fixtureCollection))
		let item = "Grape"
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCollection[0], item), (item, fixtureCollection[0])].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0])
				XCTAssertEqual(expected.1, tuples[index].1[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key].insert(element: item, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<Bag<String>?>("observeCollectionOptionalKeyCombine")
		let item = "Grape"
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(String?, String?)] = [(nil, fixtureCollection[0]), (fixtureCollection[0], item), (item, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0?[0])
				XCTAssertEqual(expected.1, tuples[index].1?[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = Bag(items: fixtureCollection)
		DefaultsEnum[key]?.insert(element: item, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[Bag<String>]>("observeCollectionArrayKeyCombine", default: [.init(items: fixtureCollection)])
		let item = "Grape"
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCollection[0], item), (item, fixtureCollection[0])].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0][0])
				XCTAssertEqual(expected.1, tuples[index].1[0][0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0].insert(element: item, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: Bag<String>]>("observeCollectionArrayKeyCombine", default: ["0": .init(items: fixtureCollection)])
		let item = "Grape"
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCollection[0], item), (item, fixtureCollection[0])].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"]?[0])
				XCTAssertEqual(expected.1, tuples[index].1["0"]?[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"]?.insert(element: item, at: 0)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<Bag<String>>("observeCollectionKey", default: .init(items: fixtureCollection))
		let item = "Grape"
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0], fixtureCollection[0])
			XCTAssertEqual(change.newValue[0], item)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key].insert(element: item, at: 0)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<Bag<String>?>("observeCollectionOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue?[0], fixtureCollection[0])
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = .init(items: fixtureCollection)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[Bag<String>]>("observeCollectionArrayKey", default: [.init(items: fixtureCollection)])
		let item = "Grape"
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0][0], fixtureCollection[0])
			XCTAssertEqual(change.newValue[0][0], item)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key][0].insert(element: item, at: 0)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKey() {
		let key = DefaultsEnum.Key<[String: Bag<String>]>("observeCollectionDictionaryKey", default: ["0": .init(items: fixtureCollection)])
		let item = "Grape"
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue["0"]?[0], fixtureCollection[0])
			XCTAssertEqual(change.newValue["0"]?[0], item)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["0"]?.insert(element: item, at: 0)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
