import Foundation
import Combine
import XCTest
@testable import Defaults

let fixtureURL = URL(string: "https://sindresorhus.com")!
let fixtureFileURL = URL(string: "file://~/icon.png")!
let fixtureURL2 = URL(string: "https://example.com")!
let fixtureDate = Date()

extension DefaultsEnum.Keys {
	static let key = Key<Bool>("key", default: false)
	static let url = Key<URL>("url", default: fixtureURL)
	static let file = Key<URL>("fileURL", default: fixtureFileURL)
	static let data = Key<Data>("data", default: Data([]))
	static let date = Key<Date>("date", default: fixtureDate)
	static let uuid = Key<UUID?>("uuid")
	static let defaultDynamicDate = Key<Date>("defaultDynamicOptionalDate") { Date(timeIntervalSince1970: 0) }
	static let defaultDynamicOptionalDate = Key<Date?>("defaultDynamicOptionalDate") { Date(timeIntervalSince1970: 1) }
}

final class DefaultsTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<Bool>("independentKey", default: false)
		XCTAssertFalse(DefaultsEnum[key])
		DefaultsEnum[key] = true
		XCTAssertTrue(DefaultsEnum[key])
	}

	func testValidKeyName() {
		let validKey = DefaultsEnum.Key<Bool>("test", default: false)
		let containsDotKey = DefaultsEnum.Key<Bool>("test.a", default: false)
		let startsWithAtKey = DefaultsEnum.Key<Bool>("@test", default: false)
		XCTAssertTrue(DefaultsEnum.isValidKeyPath(name: validKey.name))
		XCTAssertFalse(DefaultsEnum.isValidKeyPath(name: containsDotKey.name))
		XCTAssertFalse(DefaultsEnum.isValidKeyPath(name: startsWithAtKey.name))
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<Bool?>("independentOptionalKey")
		let url = DefaultsEnum.Key<URL?>("independentOptionalURLKey")
		XCTAssertNil(DefaultsEnum[key])
		XCTAssertNil(DefaultsEnum[url])
		DefaultsEnum[key] = true
		DefaultsEnum[url] = fixtureURL
		XCTAssertTrue(DefaultsEnum[key]!)
		XCTAssertEqual(DefaultsEnum[url], fixtureURL)
		DefaultsEnum[key] = nil
		DefaultsEnum[url] = nil
		XCTAssertNil(DefaultsEnum[key])
		XCTAssertNil(DefaultsEnum[url])
		DefaultsEnum[key] = false
		DefaultsEnum[url] = fixtureURL2
		XCTAssertFalse(DefaultsEnum[key]!)
		XCTAssertEqual(DefaultsEnum[url], fixtureURL2)
	}

	func testInitializeDynamicDateKey() {
		_ = DefaultsEnum.Key<Date>("independentInitializeDynamicDateKey") {
			XCTFail("Init dynamic key should not trigger getter")
			return Date()
		}
		_ = DefaultsEnum.Key<Date?>("independentInitializeDynamicOptionalDateKey") {
			XCTFail("Init dynamic optional key should not trigger getter")
			return Date()
		}
	}

	func testKeyRegistersDefault() {
		let keyName = "registersDefault"
		XCTAssertFalse(UserDefaults.standard.bool(forKey: keyName))
		_ = DefaultsEnum.Key<Bool>(keyName, default: true)
		XCTAssertTrue(UserDefaults.standard.bool(forKey: keyName))

		// Test that it works with multiple keys with `DefaultsEnum`.
		let keyName2 = "registersDefault2"
		_ = DefaultsEnum.Key<String>(keyName2, default: keyName2)
		XCTAssertEqual(UserDefaults.standard.string(forKey: keyName2), keyName2)
	}

	func testKeyWithUserDefaultSubscript() {
		let key = DefaultsEnum.Key<Bool>("keyWithUserDeaultSubscript", default: false)
		XCTAssertFalse(UserDefaults.standard[key])
		UserDefaults.standard[key] = true
		XCTAssertTrue(UserDefaults.standard[key])
	}

	func testKeys() {
		XCTAssertFalse(DefaultsEnum[.key])
		DefaultsEnum[.key] = true
		XCTAssertTrue(DefaultsEnum[.key])
	}

	func testUrlType() {
		XCTAssertEqual(DefaultsEnum[.url], fixtureURL)
		let newUrl = URL(string: "https://twitter.com")!
		DefaultsEnum[.url] = newUrl
		XCTAssertEqual(DefaultsEnum[.url], newUrl)
	}

	func testDataType() {
		XCTAssertEqual(DefaultsEnum[.data], Data([]))
		let newData = Data([0xFF])
		DefaultsEnum[.data] = newData
		XCTAssertEqual(DefaultsEnum[.data], newData)
	}

	func testDateType() {
		XCTAssertEqual(DefaultsEnum[.date], fixtureDate)
		let newDate = Date()
		DefaultsEnum[.date] = newDate
		XCTAssertEqual(DefaultsEnum[.date], newDate)
	}

	func testDynamicDateType() {
		XCTAssertEqual(DefaultsEnum[.defaultDynamicDate], Date(timeIntervalSince1970: 0))
		let next = Date(timeIntervalSince1970: 1)
		DefaultsEnum[.defaultDynamicDate] = next
		XCTAssertEqual(DefaultsEnum[.defaultDynamicDate], next)
		XCTAssertEqual(UserDefaults.standard.object(forKey: DefaultsEnum.Key<Date>.defaultDynamicDate.name) as! Date, next)
		DefaultsEnum.Key<Date>.defaultDynamicDate.reset()
		XCTAssertEqual(DefaultsEnum[.defaultDynamicDate], Date(timeIntervalSince1970: 0))
	}

	func testDynamicOptionalDateType() {
		XCTAssertEqual(DefaultsEnum[.defaultDynamicOptionalDate], Date(timeIntervalSince1970: 1))
		let next = Date(timeIntervalSince1970: 2)
		DefaultsEnum[.defaultDynamicOptionalDate] = next
		XCTAssertEqual(DefaultsEnum[.defaultDynamicOptionalDate], next)
		XCTAssertEqual(UserDefaults.standard.object(forKey: DefaultsEnum.Key<Date>.defaultDynamicOptionalDate.name) as! Date, next)
		DefaultsEnum[.defaultDynamicOptionalDate] = nil
		XCTAssertEqual(DefaultsEnum[.defaultDynamicOptionalDate], Date(timeIntervalSince1970: 1))
		XCTAssertNil(UserDefaults.standard.object(forKey: DefaultsEnum.Key<Date>.defaultDynamicOptionalDate.name))
	}

	func testFileURLType() {
		XCTAssertEqual(DefaultsEnum[.file], fixtureFileURL)
	}

	func testUUIDType() {
		let fixture = UUID()
		DefaultsEnum[.uuid] = fixture
		XCTAssertEqual(DefaultsEnum[.uuid], fixture)
	}

	func testRemoveAll() {
		let key = DefaultsEnum.Key<Bool>("removeAll", default: false)
		let key2 = DefaultsEnum.Key<Bool>("removeAll2", default: false)
		DefaultsEnum[key] = true
		DefaultsEnum[key2] = true
		XCTAssertTrue(DefaultsEnum[key])
		XCTAssertTrue(DefaultsEnum[key2])
		DefaultsEnum.removeAll()
		XCTAssertFalse(DefaultsEnum[key])
		XCTAssertFalse(DefaultsEnum[key2])
	}

	func testCustomSuite() {
		let customSuite = UserDefaults(suiteName: "com.sindresorhus.customSuite")!
		let key = DefaultsEnum.Key<Bool>("customSuite", default: false, suite: customSuite)
		XCTAssertFalse(customSuite[key])
		XCTAssertFalse(DefaultsEnum[key])
		DefaultsEnum[key] = true
		XCTAssertTrue(customSuite[key])
		XCTAssertTrue(DefaultsEnum[key])
		DefaultsEnum.removeAll(suite: customSuite)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<Bool>("observeKey", default: false)
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(false, true), (true, false)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = true
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<Bool?>("observeOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValues: [(Bool?, Bool?)] = [(nil, true), (true, false), (false, nil)]

		let cancellable = publisher.sink { actualValues in
			for (expected, actual) in zip(expectedValues, actualValues) {
				XCTAssertEqual(expected.0, actual.0)
				XCTAssertEqual(expected.1, actual.1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = true
		DefaultsEnum[key] = false
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testDynamicOptionalDateTypeCombine() {
		let first = Date(timeIntervalSince1970: 0)
		let second = Date(timeIntervalSince1970: 1)
		let third = Date(timeIntervalSince1970: 2)
		let key = DefaultsEnum.Key<Date?>("combineDynamicOptionalDateKey") { first }
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValues: [(Date?, Date?)] = [(first, second), (second, third), (third, first)]

		let cancellable = publisher.sink { actualValues in
			for (expected, actual) in zip(expectedValues, actualValues) {
				XCTAssertEqual(expected.0, actual.0)
				XCTAssertEqual(expected.1, actual.1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = second
		DefaultsEnum[key] = third
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveMultipleKeysCombine() {
		let key1 = DefaultsEnum.Key<String>("observeKey1", default: "x")
		let key2 = DefaultsEnum.Key<Bool>("observeKey2", default: true)
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum.publisher(keys: key1, key2, options: []).collect(2)

		let cancellable = publisher.sink { _ in
			expect.fulfill()
		}

		DefaultsEnum[key1] = "y"
		DefaultsEnum[key2] = false
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveMultipleOptionalKeysCombine() {
		let key1 = DefaultsEnum.Key<String?>("observeOptionalKey1")
		let key2 = DefaultsEnum.Key<Bool?>("observeOptionalKey2")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum.publisher(keys: key1, key2, options: []).collect(2)

		let cancellable = publisher.sink { _ in
			expect.fulfill()
		}

		DefaultsEnum[key1] = "x"
		DefaultsEnum[key2] = false
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testReceiveValueBeforeSubscriptionCombine() {
		let key = DefaultsEnum.Key<String>("receiveValueBeforeSubscription", default: "hello")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key)
			.map(\.newValue)
			.eraseToAnyPublisher()
			.collect(2)

		let cancellable = publisher.sink { values in
			XCTAssertEqual(["hello", "world"], values)
			expect.fulfill()
		}

		DefaultsEnum[key] = "world"
		cancellable.cancel()
		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<Bool>("observeKey", default: false)
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertFalse(change.oldValue)
			XCTAssertTrue(change.newValue)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = true

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<Bool?>("observeOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertTrue(change.newValue!)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = true

		waitForExpectations(timeout: 10)
	}

	func testObserveMultipleKeys() {
		let key1 = DefaultsEnum.Key<String>("observeKey1", default: "x")
		let key2 = DefaultsEnum.Key<Bool>("observeKey2", default: true)
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

		DefaultsEnum[key1] = "y"
		DefaultsEnum[key2] = false
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveKeyURL() {
		let key = DefaultsEnum.Key<URL>("observeKeyURL", default: fixtureURL)
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, fixtureURL)
			XCTAssertEqual(change.newValue, fixtureURL2)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureURL2

		waitForExpectations(timeout: 10)
	}

	func testObserveDynamicOptionalDateKey() {
		let first = Date(timeIntervalSince1970: 0)
		let second = Date(timeIntervalSince1970: 1)
		let key = DefaultsEnum.Key<Date?>("observeDynamicOptionalDate") { first }

		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, first)
			XCTAssertEqual(change.newValue, second)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = second

		waitForExpectations(timeout: 10)
	}

	func testObservePreventPropagation() {
		let key1 = DefaultsEnum.Key<Bool?>("preventPropagation0", default: nil)
		let expect = expectation(description: "No infinite recursion")

		var observation: DefaultsEnum.Observation!
		var wasInside = false
		observation = DefaultsEnum.observe(key1, options: []) { _ in
			XCTAssertFalse(wasInside)
			wasInside = true
			DefaultsEnum.withoutPropagation {
				DefaultsEnum[key1] = true
			}
			expect.fulfill()
		}

		DefaultsEnum[key1] = false
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObservePreventPropagationMultipleKeys() {
		let key1 = DefaultsEnum.Key<Bool?>("preventPropagation1", default: nil)
		let key2 = DefaultsEnum.Key<Bool?>("preventPropagation2", default: nil)
		let expect = expectation(description: "No infinite recursion")

		var observation: DefaultsEnum.Observation!
		var wasInside = false
		observation = DefaultsEnum.observe(keys: key1, key2, options: []) {
			XCTAssertFalse(wasInside)
			wasInside = true
			DefaultsEnum.withoutPropagation {
				DefaultsEnum[key1] = true
			}
			expect.fulfill()
		}

		DefaultsEnum[key1] = false
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	// This checks if the callback is still being called if the value is changed on a second thread while the initial thread is doing some long running task.
	func testObservePreventPropagationMultipleThreads() {
		let key1 = DefaultsEnum.Key<Int?>("preventPropagation3", default: nil)
		let expect = expectation(description: "No infinite recursion")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key1, options: []) { _ in
			DefaultsEnum.withoutPropagation {
				DefaultsEnum[key1]! += 1
			}
			print("--- Main Thread: \(Thread.isMainThread)")
			if !Thread.isMainThread {
				XCTAssert(DefaultsEnum[key1]! == 4)
				expect.fulfill()
			} else {
				usleep(300_000)
				print("--- Release: \(Thread.isMainThread)")
			}
		}
		DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
			DefaultsEnum[key1]! += 1
		}
		DefaultsEnum[key1] = 1
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	// Check if propagation prevention works across multiple observations.
	func testObservePreventPropagationMultipleObservations() {
		let key1 = DefaultsEnum.Key<Bool?>("preventPropagation4", default: nil)
		let key2 = DefaultsEnum.Key<Bool?>("preventPropagation5", default: nil)
		let expect = expectation(description: "No infinite recursion")

		let observation1 = DefaultsEnum.observe(key2, options: []) { _ in
			XCTFail()
		}

		let observation2 = DefaultsEnum.observe(keys: key1, key2, options: []) {
			DefaultsEnum.withoutPropagation {
				DefaultsEnum[key2] = true
			}
			expect.fulfill()
		}

		DefaultsEnum[key1] = false
		observation1.invalidate()
		observation2.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObservePreventPropagationCombine() {
		let key1 = DefaultsEnum.Key<Bool?>("preventPropagation6", default: nil)
		let expect = expectation(description: "No infinite recursion")

		var wasInside = false
		let cancellable = DefaultsEnum.publisher(key1, options: []).sink { _ in
			XCTAssertFalse(wasInside)
			wasInside = true
			DefaultsEnum.withoutPropagation {
				DefaultsEnum[key1] = true
			}
			expect.fulfill()
		}

		DefaultsEnum[key1] = false
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObservePreventPropagationMultipleKeysCombine() {
		let key1 = DefaultsEnum.Key<Bool?>("preventPropagation7", default: nil)
		let key2 = DefaultsEnum.Key<Bool?>("preventPropagation8", default: nil)
		let expect = expectation(description: "No infinite recursion")

		var wasInside = false
		let cancellable = DefaultsEnum.publisher(keys: key1, key2, options: []).sink { _ in
			XCTAssertFalse(wasInside)
			wasInside = true
			DefaultsEnum.withoutPropagation {
				DefaultsEnum[key1] = true
			}
			expect.fulfill()
		}

		DefaultsEnum[key2] = false
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObservePreventPropagationModifiersCombine() {
		let key1 = DefaultsEnum.Key<Bool?>("preventPropagation9", default: nil)
		let expect = expectation(description: "No infinite recursion")

		var wasInside = false
		var cancellable: AnyCancellable!
		cancellable = DefaultsEnum.publisher(key1, options: [])
			.receive(on: DispatchQueue.main)
			.delay(for: 0.5, scheduler: DispatchQueue.global())
			.sink { _ in
				XCTAssertFalse(wasInside)
				wasInside = true
				DefaultsEnum.withoutPropagation {
					DefaultsEnum[key1] = true
				}
				expect.fulfill()
				cancellable.cancel()
			}

		DefaultsEnum[key1] = false

		waitForExpectations(timeout: 10)
	}

	func testRemoveDuplicatesObserveKeyCombine() {
		let key = DefaultsEnum.Key<Bool>("observeKey", default: false)
		let expect = expectation(description: "Observation closure being called")

		let inputArray = [true, false, false, false, false, false, false, true]
		let expectedArray = [true, false, true]

		let cancellable = DefaultsEnum
			.publisher(key, options: [])
			.removeDuplicates()
			.map(\.newValue)
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
			DefaultsEnum[key] = $0
		}

		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testRemoveDuplicatesOptionalObserveKeyCombine() {
		let key = DefaultsEnum.Key<Bool?>("observeOptionalKey", default: nil)
		let expect = expectation(description: "Observation closure being called")

		let inputArray = [true, nil, nil, nil, false, false, false, nil]
		let expectedArray = [true, nil, false, nil]

		let cancellable = DefaultsEnum
			.publisher(key, options: [])
			.removeDuplicates()
			.map(\.newValue)
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
			DefaultsEnum[key] = $0
		}

		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testResetKey() {
		let defaultFixture1 = "foo1"
		let defaultFixture2 = 0
		let newFixture1 = "bar1"
		let newFixture2 = 1
		let key1 = DefaultsEnum.Key<String>("key1", default: defaultFixture1)
		let key2 = DefaultsEnum.Key<Int>("key2", default: defaultFixture2)
		DefaultsEnum[key1] = newFixture1
		DefaultsEnum[key2] = newFixture2
		DefaultsEnum.reset(key1)
		XCTAssertEqual(DefaultsEnum[key1], defaultFixture1)
		XCTAssertEqual(DefaultsEnum[key2], newFixture2)
	}

	func testResetMultipleKeys() {
		let defaultFxiture1 = "foo1"
		let defaultFixture2 = 0
		let defaultFixture3 = "foo3"
		let newFixture1 = "bar1"
		let newFixture2 = 1
		let newFixture3 = "bar3"
		let key1 = DefaultsEnum.Key<String>("akey1", default: defaultFxiture1)
		let key2 = DefaultsEnum.Key<Int>("akey2", default: defaultFixture2)
		let key3 = DefaultsEnum.Key<String>("akey3", default: defaultFixture3)
		DefaultsEnum[key1] = newFixture1
		DefaultsEnum[key2] = newFixture2
		DefaultsEnum[key3] = newFixture3
		DefaultsEnum.reset(key1, key2)
		XCTAssertEqual(DefaultsEnum[key1], defaultFxiture1)
		XCTAssertEqual(DefaultsEnum[key2], defaultFixture2)
		XCTAssertEqual(DefaultsEnum[key3], newFixture3)
	}

	func testResetMultipleOptionalKeys() {
		let newFixture1 = "bar1"
		let newFixture2 = 1
		let newFixture3 = "bar3"
		let key1 = DefaultsEnum.Key<String?>("aoptionalKey1")
		let key2 = DefaultsEnum.Key<Int?>("aoptionalKey2")
		let key3 = DefaultsEnum.Key<String?>("aoptionalKey3")
		DefaultsEnum[key1] = newFixture1
		DefaultsEnum[key2] = newFixture2
		DefaultsEnum[key3] = newFixture3
		DefaultsEnum.reset(key1, key2)
		XCTAssertNil(DefaultsEnum[key1])
		XCTAssertNil(DefaultsEnum[key2])
		XCTAssertEqual(DefaultsEnum[key3], newFixture3)
	}

	func testObserveWithLifetimeTie() {
		let key = DefaultsEnum.Key<Bool>("lifetimeTie", default: false)
		let expect = expectation(description: "Observation closure being called")

		weak var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { _ in
			observation.invalidate()
			expect.fulfill()
		}
			.tieToLifetime(of: self)

		DefaultsEnum[key] = true

		waitForExpectations(timeout: 10)
	}

	func testObserveWithLifetimeTieManualBreak() {
		let key = DefaultsEnum.Key<Bool>("lifetimeTieManualBreak", default: false)

		weak var observation: DefaultsEnum.Observation? = DefaultsEnum.observe(key, options: []) { _ in }.tieToLifetime(of: self)
		observation!.removeLifetimeTie()

		for index in 1...10 {
			if observation == nil {
				break
			}

			sleep(1)

			if index == 10 {
				XCTFail()
			}
		}
	}

	func testImmediatelyFinishingPublisherCombine() {
		let key = DefaultsEnum.Key<Bool>("observeKey", default: false)
		let expect = expectation(description: "Observation closure being called without crashing")

		let cancellable = DefaultsEnum
			.publisher(key, options: [.initial])
			.first()
			.sink { _ in
				expect.fulfill()
			}

		cancellable.cancel()
		waitForExpectations(timeout: 10)
	}

	func testKeyEquatable() {
		XCTAssertEqual(DefaultsEnum.Key<Bool>("equatableKeyTest", default: false), DefaultsEnum.Key<Bool>("equatableKeyTest", default: false))
	}

	func testKeyHashable() {
		_ = Set([DefaultsEnum.Key<Bool>("hashableKeyTest", default: false)])
	}

	func testUpdates() async {
		let key = DefaultsEnum.Key<Bool>("updatesKey", default: false)

		async let waiter = DefaultsEnum.updates(key, initial: false).first { $0 }

		try? await Task.sleep(seconds: 0.1)

		DefaultsEnum[key] = true

		guard let result = await waiter else {
			XCTFail()
			return
		}

		XCTAssertTrue(result)
	}

	func testUpdatesMultipleKeys() async {
		let key1 = DefaultsEnum.Key<Bool>("updatesMultipleKey1", default: false)
		let key2 = DefaultsEnum.Key<Bool>("updatesMultipleKey2", default: false)
		let counter = Counter()

		async let waiter: Void = {
			for await _ in DefaultsEnum.updates([key1, key2], initial: false) {
				await counter.increment()

				if await counter.count == 2 {
					break
				}
			}
		}()

		try? await Task.sleep(seconds: 0.1)

		DefaultsEnum[key1] = true
		DefaultsEnum[key2] = true

		await waiter

		let count = await counter.count
		XCTAssertEqual(count, 2)
	}
}

actor Counter {
	private var _count = 0

	var count: Int { _count }

	func increment() {
		_count += 1
	}
}

// TODO: Remove when testing on macOS 13.
extension Task<Never, Never> {
	static func sleep(seconds: TimeInterval) async throws {
		try await sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
	}
}
