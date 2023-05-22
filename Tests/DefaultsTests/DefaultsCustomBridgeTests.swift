import Foundation
import Defaults
import XCTest

public struct User: Hashable, Equatable {
	var username: String
	var password: String
}

extension User: DefaultsEnum.Serializable {
	public static let bridge = DefaultsUserBridge()
}

public final class DefaultsUserBridge: DefaultsEnum.Bridge {
	public typealias Value = User
	public typealias Serializable = [String: String]

	public func serialize(_ value: Value?) -> Serializable? {
		guard let value else {
			return nil
		}

		return ["username": value.username, "password": value.password]
	}

	public func deserialize(_ object: Serializable?) -> Value? {
		guard
			let object,
			let username = object["username"],
			let password = object["password"]
		else {
			return nil
		}

		return User(username: username, password: password)
	}
}

private let fixtureCustomBridge = User(username: "hank121314", password: "123456")

struct PlainHourMinuteTimeRange: Hashable, Codable {
	var start: PlainHourMinuteTime
	var end: PlainHourMinuteTime
}

extension PlainHourMinuteTimeRange: DefaultsEnum.Serializable {
	struct Bridge: DefaultsEnum.Bridge {
		typealias Value = PlainHourMinuteTimeRange
		typealias Serializable = [PlainHourMinuteTime]

		func serialize(_ value: Value?) -> Serializable? {
			guard let value else {
				return nil
			}

			return [value.start, value.end]
		}

		func deserialize(_ object: Serializable?) -> Value? {
			guard
				let array = object,
				let start = array[safe: 0],
				let end = array[safe: 1]
			else {
				return nil
			}

			return .init(start: start, end: end)
		}
	}

	static let bridge = Bridge()
}

struct PlainHourMinuteTime: Hashable, Codable, DefaultsEnum.Serializable {
	var hour: Int
	var minute: Int
}

extension Collection {
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}

extension DefaultsEnum.Keys {
	fileprivate static let customBridge = Key<User>("customBridge", default: fixtureCustomBridge)
	fileprivate static let customBridgeArray = Key<[User]>("array_customBridge", default: [fixtureCustomBridge])
	fileprivate static let customBridgeDictionary = Key<[String: User]>("dictionary_customBridge", default: ["0": fixtureCustomBridge])
}

final class DefaultsCustomBridge: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testKey() {
		let key = DefaultsEnum.Key<User>("independentCustomBridgeKey", default: fixtureCustomBridge)
		XCTAssertEqual(DefaultsEnum[key], fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[key] = newUser
		XCTAssertEqual(DefaultsEnum[key], newUser)
	}

	func testOptionalKey() {
		let key = DefaultsEnum.Key<User?>("independentCustomBridgeOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = fixtureCustomBridge
		XCTAssertEqual(DefaultsEnum[key], fixtureCustomBridge)
	}

	func testArrayKey() {
		let user = User(username: "hank121314", password: "123456")
		let key = DefaultsEnum.Key<[User]>("independentCustomBridgeArrayKey", default: [user])
		XCTAssertEqual(DefaultsEnum[key][0], user)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[key][0] = newUser
		XCTAssertEqual(DefaultsEnum[key][0], newUser)
	}

	func testArrayOptionalKey() {
		let key = DefaultsEnum.Key<[User]?>("independentCustomBridgeArrayOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		let newUser = User(username: "hank121314", password: "123456")
		DefaultsEnum[key] = [newUser]
		XCTAssertEqual(DefaultsEnum[key]?[0], newUser)
		DefaultsEnum[key] = nil
		XCTAssertNil(DefaultsEnum[key])
	}

	func testNestedArrayKey() {
		let key = DefaultsEnum.Key<[[User]]>("independentCustomBridgeNestedArrayKey", default: [[fixtureCustomBridge], [fixtureCustomBridge]])
		XCTAssertEqual(DefaultsEnum[key][0][0].username, fixtureCustomBridge.username)
		let newUsername = "John"
		let newPassword = "7891011"
		DefaultsEnum[key][0][0] = User(username: newUsername, password: newPassword)
		XCTAssertEqual(DefaultsEnum[key][0][0].username, newUsername)
		XCTAssertEqual(DefaultsEnum[key][0][0].password, newPassword)
		XCTAssertEqual(DefaultsEnum[key][1][0].username, fixtureCustomBridge.username)
		XCTAssertEqual(DefaultsEnum[key][1][0].password, fixtureCustomBridge.password)
	}

	func testArrayDictionaryKey() {
		let key = DefaultsEnum.Key<[[String: User]]>("independentCustomBridgeArrayDictionaryKey", default: [["0": fixtureCustomBridge], ["0": fixtureCustomBridge]])
		XCTAssertEqual(DefaultsEnum[key][0]["0"]?.username, fixtureCustomBridge.username)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[key][0]["0"] = newUser
		XCTAssertEqual(DefaultsEnum[key][0]["0"], newUser)
		XCTAssertEqual(DefaultsEnum[key][1]["0"], fixtureCustomBridge)
	}

	func testSetKey() {
		let key = DefaultsEnum.Key<Set<User>>("independentCustomBridgeSetKey", default: [fixtureCustomBridge])
		XCTAssertEqual(DefaultsEnum[key].first, fixtureCustomBridge)
		DefaultsEnum[key].insert(fixtureCustomBridge)
		XCTAssertEqual(DefaultsEnum[key].count, 1)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[key].insert(newUser)
		XCTAssertTrue(DefaultsEnum[key].contains(newUser))
	}

	func testDictionaryKey() {
		let key = DefaultsEnum.Key<[String: User]>("independentCustomBridgeDictionaryKey", default: ["0": fixtureCustomBridge])
		XCTAssertEqual(DefaultsEnum[key]["0"], fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[key]["0"] = newUser
		XCTAssertEqual(DefaultsEnum[key]["0"], newUser)
	}

	func testDictionaryOptionalKey() {
		let key = DefaultsEnum.Key<[String: User]?>("independentCustomBridgeDictionaryOptionalKey")
		XCTAssertNil(DefaultsEnum[key])
		DefaultsEnum[key] = ["0": fixtureCustomBridge]
		XCTAssertEqual(DefaultsEnum[key]?["0"], fixtureCustomBridge)
	}

	func testDictionaryArrayKey() {
		let key = DefaultsEnum.Key<[String: [User]]>("independentCustomBridgeDictionaryArrayKey", default: ["0": [fixtureCustomBridge]])
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[key]["0"]?[0] = newUser
		DefaultsEnum[key]["0"]?.append(fixtureCustomBridge)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], newUser)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[0], newUser)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1], fixtureCustomBridge)
		XCTAssertEqual(DefaultsEnum[key]["0"]?[1], fixtureCustomBridge)
	}

	func testRecursiveKey() {
		let start = PlainHourMinuteTime(hour: 1, minute: 0)
		let end = PlainHourMinuteTime(hour: 2, minute: 0)
		let range = PlainHourMinuteTimeRange(start: start, end: end)
		let key = DefaultsEnum.Key<PlainHourMinuteTimeRange>("independentCustomBridgeRecursiveKey", default: range)
		XCTAssertEqual(DefaultsEnum[key].start.hour, range.start.hour)
		XCTAssertEqual(DefaultsEnum[key].start.minute, range.start.minute)
		XCTAssertEqual(DefaultsEnum[key].end.hour, range.end.hour)
		XCTAssertEqual(DefaultsEnum[key].end.minute, range.end.minute)
		guard let rawValue = UserDefaults.standard.array(forKey: key.name) as? [String] else {
			XCTFail("rawValue should not be nil")
			return
		}
		XCTAssertEqual(rawValue, [#"{"minute":0,"hour":1}"#, #"{"minute":0,"hour":2}"#])
		let next_start = PlainHourMinuteTime(hour: 3, minute: 58)
		let next_end = PlainHourMinuteTime(hour: 4, minute: 59)
		let next_range = PlainHourMinuteTimeRange(start: next_start, end: next_end)
		DefaultsEnum[key] = next_range
		XCTAssertEqual(DefaultsEnum[key].start.hour, next_range.start.hour)
		XCTAssertEqual(DefaultsEnum[key].start.minute, next_range.start.minute)
		XCTAssertEqual(DefaultsEnum[key].end.hour, next_range.end.hour)
		XCTAssertEqual(DefaultsEnum[key].end.minute, next_range.end.minute)
		guard let nextRawValue = UserDefaults.standard.array(forKey: key.name) as? [String] else {
			XCTFail("nextRawValue should not be nil")
			return
		}
		XCTAssertEqual(nextRawValue, [#"{"minute":58,"hour":3}"#, #"{"minute":59,"hour":4}"#])
	}

	func testType() {
		XCTAssertEqual(DefaultsEnum[.customBridge], fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[.customBridge] = newUser
		XCTAssertEqual(DefaultsEnum[.customBridge], newUser)
	}

	func testArrayType() {
		XCTAssertEqual(DefaultsEnum[.customBridgeArray][0], fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[.customBridgeArray][0] = newUser
		XCTAssertEqual(DefaultsEnum[.customBridgeArray][0], newUser)
	}

	func testDictionaryType() {
		XCTAssertEqual(DefaultsEnum[.customBridgeDictionary]["0"], fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		DefaultsEnum[.customBridgeDictionary]["0"] = newUser
		XCTAssertEqual(DefaultsEnum[.customBridgeDictionary]["0"], newUser)
	}

	func testObserveKeyCombine() {
		let key = DefaultsEnum.Key<User>("observeCustomBridgeKeyCombine", default: fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCustomBridge, newUser), (newUser, fixtureCustomBridge)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = newUser
		DefaultsEnum[key] = fixtureCustomBridge
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKeyCombine() {
		let key = DefaultsEnum.Key<User?>("observeCustomBridgeOptionalKeyCombine")
		let newUser = User(username: "sindresorhus", password: "123456789")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(3)

		let expectedValue: [(User?, User?)] = [(nil, fixtureCustomBridge), (fixtureCustomBridge, newUser), (newUser, nil)]

		let cancellable = publisher.sink { tuples in
			for (index, expected) in expectedValue.enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureCustomBridge
		DefaultsEnum[key] = newUser
		DefaultsEnum.reset(key)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKeyCombine() {
		let key = DefaultsEnum.Key<[User]>("observeCustomBridgeArrayKeyCombine", default: [fixtureCustomBridge])
		let newUser = User(username: "sindresorhus", password: "123456789")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [([fixtureCustomBridge], [newUser]), ([newUser], [newUser, fixtureCustomBridge])].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0)
				XCTAssertEqual(expected.1, tuples[index].1)
			}

			expect.fulfill()
		}

		DefaultsEnum[key][0] = newUser
		DefaultsEnum[key].append(fixtureCustomBridge)
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryCombine() {
		let key = DefaultsEnum.Key<[String: User]>("observeCustomBridgeDictionaryKeyCombine", default: ["0": fixtureCustomBridge])
		let newUser = User(username: "sindresorhus", password: "123456789")
		let expect = expectation(description: "Observation closure being called")

		let publisher = DefaultsEnum
			.publisher(key, options: [])
			.map { ($0.oldValue, $0.newValue) }
			.collect(2)

		let cancellable = publisher.sink { tuples in
			for (index, expected) in [(fixtureCustomBridge, newUser), (newUser, fixtureCustomBridge)].enumerated() {
				XCTAssertEqual(expected.0, tuples[index].0["0"])
				XCTAssertEqual(expected.1, tuples[index].1["0"])
			}

			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = newUser
		DefaultsEnum[key]["0"] = fixtureCustomBridge
		cancellable.cancel()

		waitForExpectations(timeout: 10)
	}

	func testObserveKey() {
		let key = DefaultsEnum.Key<User>("observeCustomBridgeKey", default: fixtureCustomBridge)
		let newUser = User(username: "sindresorhus", password: "123456789")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue, fixtureCustomBridge)
			XCTAssertEqual(change.newValue, newUser)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = newUser
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveOptionalKey() {
		let key = DefaultsEnum.Key<User?>("observeCustomBridgeOptionalKey")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertNil(change.oldValue)
			XCTAssertEqual(change.newValue, fixtureCustomBridge)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key] = fixtureCustomBridge
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveArrayKey() {
		let key = DefaultsEnum.Key<[User]>("observeCustomBridgeArrayKey", default: [fixtureCustomBridge])
		let newUser = User(username: "sindresorhus", password: "123456789")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue[0], fixtureCustomBridge)
			XCTAssertEqual(change.newValue[0], newUser)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key][0] = newUser
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}

	func testObserveDictionaryKey() {
		let key = DefaultsEnum.Key<[String: User]>("observeCustomBridgeDictionaryKey", default: ["0": fixtureCustomBridge])
		let newUser = User(username: "sindresorhus", password: "123456789")
		let expect = expectation(description: "Observation closure being called")

		var observation: DefaultsEnum.Observation!
		observation = DefaultsEnum.observe(key, options: []) { change in
			XCTAssertEqual(change.oldValue["0"], fixtureCustomBridge)
			XCTAssertEqual(change.newValue["0"], newUser)
			observation.invalidate()
			expect.fulfill()
		}

		DefaultsEnum[key]["0"] = newUser
		observation.invalidate()

		waitForExpectations(timeout: 10)
	}
}
