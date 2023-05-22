#if canImport(AppKit)
import Foundation
import Defaults
import XCTest
import AppKit

private let fixtureColor = NSColor(red: CGFloat(103) / CGFloat(0xFF), green: CGFloat(132) / CGFloat(0xFF), blue: CGFloat(255) / CGFloat(0xFF), alpha: 1)
private let fixtureColor1 = NSColor(red: CGFloat(255) / CGFloat(0xFF), green: CGFloat(241) / CGFloat(0xFF), blue: CGFloat(180) / CGFloat(0xFF), alpha: 1)
private let fixtureColor2 = NSColor(red: CGFloat(255) / CGFloat(0xFF), green: CGFloat(180) / CGFloat(0xFF), blue: CGFloat(194) / CGFloat(0xFF), alpha: 1)

extension DefaultsEnum.Keys {
	fileprivate static let color = DefaultsEnum.Key<NSColor>("NSColor", default: fixtureColor)
	fileprivate static let colorArray = DefaultsEnum.Key<[NSColor]>("NSColorArray", default: [fixtureColor])
	fileprivate static let colorDictionary = DefaultsEnum.Key<[String: NSColor]>("NSColorArray", default: ["0": fixtureColor])
}

final class DefaultsNSColorTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<NSColor>("independentNSColorKey", default: fixtureColor)
		XCTAssertTrue(DefaultsEnum[key].isEqual(fixtureColor))
		DefaultsEnum[key] = fixtureColor1
		XCTAssertTrue(DefaultsEnum[key].isEqual(fixtureColor1))
	}

	func testPreservesColorSpace() {
		let fixture = NSColor(displayP3Red: 1, green: 0.3, blue: 0.7, alpha: 1)
		let key = DefaultsEnum.Key<NSColor?>("independentNSColorPreservesColorSpaceKey")
		DefaultsEnum[key] = fixture
		XCTAssertEqual(DefaultsEnum[key]?.colorSpace, fixture.colorSpace)
		XCTAssertEqual(DefaultsEnum[key]?.cgColor.colorSpace, fixture.cgColor.colorSpace)
		XCTAssertEqual(DefaultsEnum[key], fixture)
		XCTAssertEqual(DefaultsEnum[key]?.cgColor, fixture.cgColor)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<NSColor?>("independentNSColorOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = fixtureColor
		XCTAssertTrue(DefaultsEnum[key]?.isEqual(fixtureColor) ?? false)
	}

	func testArrayKey() {
		let key = DefaultsEnum.Key<[NSColor]>("independentNSColorArrayKey", default: [fixtureColor])
		XCTAssertTrue(DefaultsEnum[key][0].isEqual(fixtureColor))
		DefaultsEnum[key].append(fixtureColor1)
		XCTAssertTrue(DefaultsEnum[key][1].isEqual(fixtureColor1))
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[NSColor]?>("independentNSColorOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = [fixtureColor]
		DefaultsEnum[key]?.append(fixtureColor1)
		XCTAssertTrue(DefaultsEnum[key]?[0].isEqual(fixtureColor) ?? false)
		XCTAssertTrue(DefaultsEnum[key]?[1].isEqual(fixtureColor1) ?? false)
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[NSColor]]>("independentNSColorNestedArrayKey", default: [[fixtureColor]])
		XCTAssertTrue(DefaultsEnum[key][0][0].isEqual(fixtureColor))
		DefaultsEnum[key][0].append(fixtureColor1)
		DefaultsEnum[key].append([fixtureColor2])
		XCTAssertTrue(DefaultsEnum[key][0][1].isEqual(fixtureColor1))
		XCTAssertTrue(DefaultsEnum[key][1][0].isEqual(fixtureColor2))
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: NSColor]]>("independentNSColorArrayDictionaryKey", default: [["0": fixtureColor]])
		XCTAssertTrue(DefaultsEnum[key][0]["0"]?.isEqual(fixtureColor) ?? false)
		DefaultsEnum[key][0]["1"] = fixtureColor1
		DefaultsEnum[key].append(["0": fixtureColor2])
		XCTAssertTrue(DefaultsEnum[key][0]["1"]?.isEqual(fixtureColor1) ?? false)
		XCTAssertTrue(DefaultsEnum[key][1]["0"]?.isEqual(fixtureColor2) ?? false)
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: NSColor]>("independentNSColorDictionaryKey", default: ["0": fixtureColor])
		XCTAssertTrue(DefaultsEnum[key]["0"]?.isEqual(fixtureColor) ?? false)
		DefaultsEnum[key]["1"] = fixtureColor1
		XCTAssertTrue(DefaultsEnum[key]["1"]?.isEqual(fixtureColor1) ?? false)
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: NSColor]?>("independentNSColorDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": fixtureColor]
		DefaultsEnum[key]?["1"] = fixtureColor1
		XCTAssertTrue(DefaultsEnum[key]?["0"]?.isEqual(fixtureColor) ?? false)
		XCTAssertTrue(DefaultsEnum[key]?["1"]?.isEqual(fixtureColor1) ?? false)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [NSColor]]>("independentNSColorDictionaryArrayKey", default: ["0": [fixtureColor]])
		XCTAssertTrue(DefaultsEnum[key]["0"]?[0].isEqual(fixtureColor) ?? false)
		DefaultsEnum[key]["0"]?.append(fixtureColor1)
		DefaultsEnum[key]["1"] = [fixtureColor2]
		XCTAssertTrue(DefaultsEnum[key]["0"]?[1].isEqual(fixtureColor1) ?? false)
		XCTAssertTrue(DefaultsEnum[key]["1"]?[0].isEqual(fixtureColor2) ?? false)
	}

	func testType() {
		XCTAssert(DefaultsEnum[.color].isEqual(fixtureColor))
		DefaultsEnum[.color] = fixtureColor1
		XCTAssert(DefaultsEnum[.color].isEqual(fixtureColor1))
	}

	func testArrayType() {
		XCTAssertTrue(DefaultsEnum[.colorArray][0].isEqual(fixtureColor))
		DefaultsEnum[.colorArray][0] = fixtureColor1
		XCTAssertTrue(DefaultsEnum[.colorArray][0].isEqual(fixtureColor1))
	}

	func testDictionaryType() {
		XCTAssertTrue(DefaultsEnum[.colorDictionary]["0"]?.isEqual(fixtureColor) ?? false)
		DefaultsEnum[.colorDictionary]["0"] = fixtureColor1
		XCTAssertTrue(DefaultsEnum[.colorDictionary]["0"]?.isEqual(fixtureColor1) ?? false)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<NSColor>("observeNSColorKeyCombine", default: fixtureColor)
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureColor, fixtureColor1), (fixtureColor1, fixtureColor)].enumerated() {
				XCTAssertTrue(expected.0.isEqual(tuples[index].0))
				XCTAssertTrue(expected.1.isEqual(tuples[index].1))
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureColor1
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<NSColor?>("observeNSColorOptionalKeyCombine")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(NSColor?, NSColor?)] = [(nil, fixtureColor), (fixtureColor, fixtureColor1), (fixtureColor1, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				guard let oldValue = expected.0 else {
					XCTAssertNil(tuples[index].0)
					continue
				}
				guard let newValue = expected.1 else {
					XCTAssertNil(tuples[index].1)
					continue
				}
				XCTAssertTrue(oldValue.isEqual(tuples[index].0))
				XCTAssertTrue(newValue.isEqual(tuples[index].1))
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureColor
		DefaultsEnum[key] = fixtureColor1
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[NSColor]>("observeNSColorArrayKeyCombine", default: [fixtureColor])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureColor, fixtureColor1), (fixtureColor1, fixtureColor)].enumerated() {
				XCTAssertTrue(expected.0.isEqual(tuples[index].0[0]))
				XCTAssertTrue(expected.1.isEqual(tuples[index].1[0]))
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0] = fixtureColor1
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKeyCombine() {
		let key = DefaultsEnum.Key<[String: NSColor]>("observeNSColorDictionaryKeyCombine", default: ["0": fixtureColor])
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureColor, fixtureColor1), (fixtureColor1, fixtureColor)].enumerated() {
				XCTAssertTrue(expected.0.isEqual(tuples[index].0["0"]))
				XCTAssertTrue(expected.1.isEqual(tuples[index].1["0"]))
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = fixtureColor1
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<NSColor>("observeNSColorKey", default: fixtureColor)
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertTrue(change.oldValue.isEqual(fixtureColor))
			XCTAssertTrue(change.newValue.isEqual(fixtureColor1))
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureColor1
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<NSColor?>("observeNSColorOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertTrue(change.newValue?.isEqual(fixtureColor) ?? false)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureColor
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[NSColor]>("observeNSColorArrayKey", default: [fixtureColor])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertTrue(change.oldValue[0].isEqual(fixtureColor))
			XCTAssertTrue(change.newValue[0].isEqual(fixtureColor))
			XCTAssertTrue(change.newValue[1].isEqual(fixtureColor1))
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key].append(fixtureColor1)
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKey() {
		let key = DefaultsEnum.Key<[String: NSColor]>("observeNSColorDictionaryKey", default: ["0": fixtureColor])
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertTrue(change.oldValue["0"]?.isEqual(fixtureColor) ?? false)
			XCTAssertTrue(change.newValue["0"]?.isEqual(fixtureColor) ?? false)
			XCTAssertTrue(change.newValue["1"]?.isEqual(fixtureColor1) ?? false)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["1"] = fixtureColor1
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
#endif
