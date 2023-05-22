import Foundation
import XCTest
import Defaults

struct DefaultsSetAlgebra<Element: DefaultsEnum.Serializable & Hashable>: SetAlgebra {
	var store = Set<Element>()

	init() {}

	init(_ sequence: __owned some Sequence<Element>) {
		self.store = Set(sequence)
	}

	init(_ store: Set<Element>) {
		self.store = store
	}

	func contains(_ member: Element) -> Bool {
		store.contains(member)
	}

	func union(_ other: Self) -> Self {
		Self(store.union(other.store))
	}

	func intersection(_ other: Self) -> Self {
		var defaultsSetAlgebra = Self()
		defaultsSetAlgebra.store = store.intersection(other.store)
		return defaultsSetAlgebra
	}

	func symmetricDifference(_ other: Self) -> Self {
		var defaultedSetAlgebra = Self()
		defaultedSetAlgebra.store = store.symmetricDifference(other.store)
		return defaultedSetAlgebra
	}

	@discardableResult
	mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
		store.insert(newMember)
	}

	mutating func remove(_ member: Element) -> Element? {
		store.remove(member)
	}

	mutating func update(with newMember: Element) -> Element? {
		store.update(with: newMember)
	}

	mutating func formUnion(_ other: DefaultsSetAlgebra) {
		store.formUnion(other.store)
	}

	mutating func formSymmetricDifference(_ other: DefaultsSetAlgebra) {
		store.formSymmetricDifference(other.store)
	}

	mutating func formIntersection(_ other: DefaultsSetAlgebra) {
		store.formIntersection(other.store)
	}
}

extension DefaultsSetAlgebra: DefaultsEnum.SetAlgebraSerializable {
	func toArray() -> [Element] {
		Array(store)
	}
}

private let fixtureSetAlgebra = 0
private let fixtureSetAlgebra1 = 1
private let fixtureSetAlgebra2 = 2
private let fixtureSetAlgebra3 = 3

extension DefaultsEnum.Keys {
	fileprivate static let setAlgebra = Key<DefaultsSetAlgebra<Int>>("setAlgebra", default: .init([fixtureSetAlgebra]))
	fileprivate static let setAlgebraArray = Key<[DefaultsSetAlgebra<Int>]>("setAlgebraArray", default: [.init([fixtureSetAlgebra])])
	fileprivate static let setAlgebraDictionary = Key<[String: DefaultsSetAlgebra<Int>]>("setAlgebraDictionary", default: ["0": .init([fixtureSetAlgebra])])
}

final class DefaultsSetAlgebraTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Int>>("independentSetAlgebraKey", default: .init([fixtureSetAlgebra]))
		DefaultsEnum[key].insert(fixtureSetAlgebra)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra]))
		DefaultsEnum[key].insert(fixtureSetAlgebra1)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Int>?>("independentSetAlgebraOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = .init([fixtureSetAlgebra])
		DefaultsEnum[key]?.insert(fixtureSetAlgebra)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra]))
		DefaultsEnum[key]?.insert(fixtureSetAlgebra1)
		XCTAssertEqual(DefaultsEnum[key], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Int>]>("independentSetAlgebraArrayKey", default: [.init([fixtureSetAlgebra])])
		DefaultsEnum[key][0].insert(fixtureSetAlgebra1)
		DefaultsEnum[key].append(.init([fixtureSetAlgebra2]))
		DefaultsEnum[key][1].insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key][0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key][1], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Int>]?>("independentSetAlgebraArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [.init([fixtureSetAlgebra])]
		DefaultsEnum[key]?[0].insert(fixtureSetAlgebra1)
		DefaultsEnum[key]?.append(.init([fixtureSetAlgebra2]))
		DefaultsEnum[key]?[1].insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key]?[0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key]?[1], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[DefaultsSetAlgebra<Int>]]>("independentSetAlgebraNestedArrayKey", default: [[.init([fixtureSetAlgebra])]])
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
		let key = DefaultsEnum.Key<[[String: DefaultsSetAlgebra<Int>]]>("independentSetAlgebraArrayDictionaryKey", default: [["0": .init([fixtureSetAlgebra])]])
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
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Int>]>("independentSetAlgebraDictionaryKey", default: ["0": .init([fixtureSetAlgebra])])
		DefaultsEnum[key]["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum[key]["1"] = .init([fixtureSetAlgebra2])
		DefaultsEnum[key]["1"]?.insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key]["0"], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key]["1"], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Int>]?>("independentSetAlgebraDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": .init([fixtureSetAlgebra])]
		DefaultsEnum[key]?["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum[key]?["1"] = .init([fixtureSetAlgebra2])
		DefaultsEnum[key]?["1"]?.insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[key]?["0"], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[key]?["1"], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [DefaultsSetAlgebra<Int>]]>("independentSetAlgebraDictionaryArrayKey", default: ["0": [.init([fixtureSetAlgebra])]])
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
		let (inserted, _) = DefaultsEnum[.setAlgebra].insert(fixtureSetAlgebra)
		XCTAssertFalse(inserted)
		DefaultsEnum[.setAlgebra].insert(fixtureSetAlgebra1)
		XCTAssertEqual(DefaultsEnum[.setAlgebra], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
	}

	func testArrayType() {
		DefaultsEnum[.setAlgebraArray][0].insert(fixtureSetAlgebra1)
		DefaultsEnum[.setAlgebraArray].append(.init([fixtureSetAlgebra2]))
		DefaultsEnum[.setAlgebraArray][1].insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[.setAlgebraArray][0], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[.setAlgebraArray][1], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testDictionaryType() {
		DefaultsEnum[.setAlgebraDictionary]["0"]?.insert(fixtureSetAlgebra1)
		DefaultsEnum[.setAlgebraDictionary]["1"] = .init([fixtureSetAlgebra2])
		DefaultsEnum[.setAlgebraDictionary]["1"]?.insert(fixtureSetAlgebra3)
		XCTAssertEqual(DefaultsEnum[.setAlgebraDictionary]["0"], .init([fixtureSetAlgebra, fixtureSetAlgebra1]))
		XCTAssertEqual(DefaultsEnum[.setAlgebraDictionary]["1"], .init([fixtureSetAlgebra2, fixtureSetAlgebra3]))
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Int>>("observeSetAlgebraKeyCombine", default: .init([fixtureSetAlgebra]))
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(DefaultsSetAlgebra<Int>, DefaultsSetAlgebra<Int>)] = [(.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), .init([fixtureSetAlgebra]))]

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
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Int>?>("observeSetAlgebraOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(DefaultsSetAlgebra<Int>?, DefaultsSetAlgebra<Int>?)] = [(nil, .init([fixtureSetAlgebra])), (.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), nil)]

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
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Int>]>("observeSetAlgebraArrayKeyCombine", default: [.init([fixtureSetAlgebra])])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(DefaultsSetAlgebra<Int>, DefaultsSetAlgebra<Int>)] = [(.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), .init([fixtureSetAlgebra]))]

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
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Int>]>("observeSetAlgebraDictionaryKeyCombine", default: ["0": .init([fixtureSetAlgebra])])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let expectedValue: [(DefaultsSetAlgebra<Int>, DefaultsSetAlgebra<Int>)] = [(.init([fixtureSetAlgebra]), .init([fixtureSetAlgebra, fixtureSetAlgebra1])), (.init([fixtureSetAlgebra, fixtureSetAlgebra1]), .init([fixtureSetAlgebra]))]

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
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Int>>("observeSetAlgebraKey", default: .init([fixtureSetAlgebra]))
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
		let key = DefaultsEnum.Key<DefaultsSetAlgebra<Int>?>("observeSetAlgebraOptionalKey")
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
		let key = DefaultsEnum.Key<[DefaultsSetAlgebra<Int>]>("observeSetAlgebraArrayKey", default: [.init([fixtureSetAlgebra])])
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
		let key = DefaultsEnum.Key<[String: DefaultsSetAlgebra<Int>]>("observeSetAlgebraDictionaryKey", default: ["0": .init([fixtureSetAlgebra])])
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
