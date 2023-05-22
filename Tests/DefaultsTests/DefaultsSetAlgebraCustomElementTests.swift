import Foundation
import XCTest
import Defaults

private struct Item: Equatable, Hashable {
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

private let fixtureSetAlgebra = Item(name: "Apple", count: 10)
private let fixtureSetAlgebra1 = Item(name: "Banana", count: 20)
private let fixtureSetAlgebra2 = Item(name: "Grape", count: 30)
private let fixtureSetAlgebra3 = Item(name: "Guava", count: 40)

extension DefaultsEnum.Keys {
	fileprivate static let setAlgebraCustomElement = Key<DefaultsSetAlgebra<Item>>("setAlgebraCustomElement", default: .init([fixtureSetAlgebra]))
	fileprivate static let setAlgebraCustomElementArray = Key<[DefaultsSetAlgebra<Item>]>("setAlgebraArrayCustomElement", default: [.init([fixtureSetAlgebra])])
	fileprivate static let setAlgebraCustomElementDictionary = Key<[String: DefaultsSetAlgebra<Item>]>("setAlgebraDictionaryCustomElement", default: ["0": .init([fixtureSetAlgebra])])
}

final class DefaultsSetAlgebraCustomElementTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Item>>("independentSetAlgebraKey", default: .init([fixtureSetAlgebra]))
		DefaultsEnum[key].insert(fixtureSetAlgebra)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra]))
		DefaultsEnum[key].insert(fixtureSetAlgebra1)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Item>?>("independentSetAlgebraOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = .init([fixtureSetAlgebra])
		DefaultsEnum[key]?.insert(fixtureSetAlgebra)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra]))
		DefaultsEnum[key]?.insert(fixtureSetAlgebra1)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Item>]>("independentSetAlgebraArrayKey", default: [.init([fixtureSetAlgebra])])
		DefaultsEnum[key][0].insert(fixtureSetAlgebra1)
		DefaultsEnum[key].append(.init([fixtureSetAlgebra2]))
		DefaultsEnum[key][1].insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key][0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key][1], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Item>]?>("independentSetAlgebraArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [.init([fixtureSetAlgebra])]
		DefaultsEnum[key]?[0].insert(fixtureSetAlgebra1)
		DefaultsEnum[key]?.append(.init([fixtureSetAlgebra2]))
		DefaultsEnum[key]?[1].insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key]?[0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key]?[1], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[DefaultsSetAlgebra<Item>]]>("independentSetAlgebraNestedArrayKey", default: [[.init([fixtureSetAlgebra])]])
		DefaultsEnum[key][0][0].insert(fixtureSetAlgebra1)
		DefaultsEnum[key][0].append(.init([fixtureSetAlgebra1]))
		DefaultsEnum[key][0][1].insert(fixtureSetAlgebra2)
		DefaultsEnum[key].append([.init([fixtureSetAlgebra3])])
		DefaultsEnum[key][1][0].insert(fixtureSetAlgebra2)
		XCTAssertEqual(DefaultsEnum[key][0][0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key][0][1], .init([fixtureSetAlgebra1, fixtureSetAlgebra2]))
		XCTAssertEqual(DefaultsEnum[key][1][0], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: DefaultsSetAlgebra<Item>]]>("independentSetAlgebraArrayDictionaryKey", default: [["0": .init([fixtureSetAlgebra])]])
		DefaultsEnum[key][0]["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum[key][0]["1"] = .init([fixtureSetAlgebra1])
		DefaultsEnum[key][0]["1"]?.insert(fixtureSetAlgebra2)
		DefaultsEnum[key].append(["0": .init([fixtureSetAlgebra3])])
		DefaultsEnum[key][1]["0"]?.insert(fixtureSetAlgebra2)
		XCTAssertEqual(DefaultsEnum[key][0]["0"], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key][0]["1"], .init([fixtureSetAlgebra1, fixtureSetAlgebra2]))
		XCTAssertEqual(DefaultsEnum[key][1]["0"], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Item>]>("independentSetAlgebraDictionaryKey", default: ["0": .init([fixtureSetAlgebra])])
		DefaultsEnum[key]["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum[key]["1"] = .init([fixtureSetAlgebra2])
		DefaultsEnum[key]["1"]?.insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key]["0"], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key]["1"], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Item>]?>("independentSetAlgebraDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": .init([fixtureSetAlgebra])]
		DefaultsEnum[key]?["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum[key]?["1"] = .init([fixtureSetAlgebra2])
		DefaultsEnum[key]?["1"]?.insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key]?["0"], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key]?["1"], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [DefaultsSetAlgebra<Item>]]>("independentSetAlgebraDictionaryArrayKey", default: ["0": [.init([fixtureSetAlgebra])]])
		DefaultsEnum[key]["0"]?[0].insert(fixtureSetAlgebra1)
		DefaultsEnum[key]["0"]?.append(.init([fixtureSetAlgebra1]))
		DefaultsEnum[key]["0"]?[1].insert(fixtureSetAlgebra2)
		DefaultsEnum[key]["1"] = [.init([fixtureSetAlgebra3])]
		DefaultsEnum[key]["1"]?[0].insert(fixtureSetAlgebra2)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1], .init([fixtureSetAlgebra1, fixtureSetAlgebra2]))
		XCTAssertEqual(DefaultsEnum[key]["1"]?[0], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testType() {
		let (inserted, _) = DefaultsEnum[.setAlgebraCustomElement].insert(fixtureSetAlgebra)
		XCTAssertFalse(inserted)
		DefaultsEnum[.setAlgebraCustomElement].insert(fixtureSetAlgebra1)
		XCTAssertEqual(DefaultsEnum[.setAlgebraCustomElement], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
	}

	func testArrayType() {
		DefaultsEnum[.setAlgebraCustomElementArray][0].insert(fixtureSetAlgebra1)
		DefaultsEnum[.setAlgebraCustomElementArray].append(.init([fixtureSetAlgebra2]))
		DefaultsEnum[.setAlgebraCustomElementArray][1].insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[.setAlgebraCustomElementArray][0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[.setAlgebraCustomElementArray][1], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testDictionaryType() {
		DefaultsEnum[.setAlgebraCustomElementDictionary]["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum[.setAlgebraCustomElementDictionary]["1"] = .init([fixtureSetAlgebra2])
		DefaultsEnum[.setAlgebraCustomElementDictionary]["1"]?.insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[.setAlgebraCustomElementDictionary]["0"], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[.setAlgebraCustomElementDictionary]["1"], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Item>>("observeSetAlgebraKeyCombine", default: .init([fixtureSetAlgebra]))
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(DefaultsSetAlgebra<Item>, DefaultsSetAlgebra<Item>)] = [(.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), .init([fixtureSetAlgebra]))]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key].insert(fixtureSetAlgebra1)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Item>?>("observeSetAlgebraOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(DefaultsSetAlgebra<Item>?, DefaultsSetAlgebra<Item>?)] = [(nil, .init([fixtureSetAlgebra])), (.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = .init([fixtureSetAlgebra])
		DefaultsEnum[key]?.insert(fixtureSetAlgebra1)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Item>]>("observeSetAlgebraArrayKeyCombine", default: [.init([fixtureSetAlgebra])])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(DefaultsSetAlgebra<Item>, DefaultsSetAlgebra<Item>)] = [(.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), .init([fixtureSetAlgebra]))]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0[0])
				XCTAssertEqual(expected.1, tuples[index].1[0])
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0].insert(fixtureSetAlgebra1)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Item>]>("observeSetAlgebraDictionaryKeyCombine", default: ["0": .init([fixtureSetAlgebra])])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(DefaultsSetAlgebra<Item>, DefaultsSetAlgebra<Item>)] = [(.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), .init([fixtureSetAlgebra]))]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"])
				XCTAssertEqual(expected.1, tuples[index].1["0"])
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Item>>("observeSetAlgebraKey", default: .init([fixtureSetAlgebra]))
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, .init([fixtureSetAlgebra]))
			XCTAssertEqual(change.newValue, .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key].insert(fixtureSetAlgebra1)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Item>?>("observeSetAlgebraOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue, .init([fixtureSetAlgebra]))
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = .init([fixtureSetAlgebra])
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Item>]>("observeSetAlgebraArrayKey", default: [.init([fixtureSetAlgebra])])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0], .init([fixtureSetAlgebra]))
			XCTAssertEqual(change.newValue[1], .init([fixtureSetAlgebra]))
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key].append(.init([fixtureSetAlgebra]))
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictioanryKey() {
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Item>]>("observeSetAlgebraDictionaryKey", default: ["0": .init([fixtureSetAlgebra])])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue["0"], .init([fixtureSetAlgebra]))
			XCTAssertEqual(change.newValue["1"], .init([fixtureSetAlgebra]))
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["1"] = .init([fixtureSetAlgebra])
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
