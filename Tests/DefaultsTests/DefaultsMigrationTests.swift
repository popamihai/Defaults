import Defaults
import Foundation
import XCTest

// Create an unique ID to test whether `LosslessStringConvertible` works.
private struct UniqueID: LosslessStringConvertible, Hashable {
	var id: Int64

	var description: String {
		"\(id)"
	}

	init(id: Int64) {
		self.id = id
	}

	init?(_ description: String) {
		self.init(id: Int64(description) ?? 0)
	}
}

private struct TimeZone: Hashable {
	var id: String
	var name: String
}

extension TimeZone: DefaultsEnum.NativeType {
	/**
	Associated `CodableForm` to `CodableTimeZone`.
	*/
	typealias CodableForm = CodableTimeZone

	static let bridge = TimeZoneBridge()
}

private struct CodableTimeZone {
	var id: String
	var name: String
}

extension CodableTimeZone: DefaultsEnum.CodableType {
	/**
	Convert from `Codable` to `Native`.
	*/
	func toNative() -> TimeZone {
		TimeZone(id: id, name: name)
	}
}

private struct TimeZoneBridge: DefaultsEnum.Bridge {
	typealias Value = TimeZone
	typealias Serializable = [String: Any]

	func serialize(_ value: TimeZone?) -> Serializable? {
		guard let value else {
			return nil
		}

		return ["id": value.id, "name": value.name]
	}

	func deserialize(_ object: Serializable?) -> TimeZone? {
		guard
			let object,
			let id = object["id"] as? String,
			let name = object["name"] as? String
		else {
			return nil
		}

		return TimeZone(id: id, name: name)
	}
}

private struct ChosenTimeZone: Codable, Hashable {
	var id: String
	var name: String
}

extension ChosenTimeZone: DefaultsEnum.Serializable {
	static let bridge = ChosenTimeZoneBridge()
}

private struct ChosenTimeZoneBridge: DefaultsEnum.Bridge {
	typealias Value = ChosenTimeZone
	typealias Serializable = [String: Any]

	func serialize(_ value: Value?) -> Serializable? {
		guard let value else {
			return nil
		}

		return ["id": value.id, "name": value.name]
	}

	func deserialize(_ object: Serializable?) -> Value? {
		guard
			let object,
			let id = object["id"] as? String,
			let name = object["name"] as? String
		else {
			return nil
		}

		return ChosenTimeZone(id: id, name: name)
	}
}

private protocol BagForm {
	associatedtype Element
	var items: [Element] { get set }
}

extension BagForm {
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
		get { items[position] }
		set { items[position] = newValue }
	}
}

private struct MyBag<Element: DefaultsEnum.NativeType>: BagForm, DefaultsEnum.CollectionSerializable, DefaultsEnum.NativeType {
	var items: [Element]

	init(_ elements: [Element]) {
		self.items = elements
	}
}

private struct CodableBag<Element: DefaultsEnum.Serializable & Codable>: BagForm, DefaultsEnum.CollectionSerializable, Codable {
	var items: [Element]

	init(_ elements: [Element]) {
		self.items = elements
	}
}

private protocol SetForm: SetAlgebra where Element: Hashable {
	var store: Set<Element> { get set }
}

extension SetForm {
	func contains(_ member: Element) -> Bool {
		store.contains(member)
	}

	func union(_ other: Self) -> Self {
		Self(store.union(other.store))
	}

	func intersection(_ other: Self) -> Self {
		var setForm = Self()
		setForm.store = store.intersection(other.store)
		return setForm
	}

	func symmetricDifference(_ other: Self) -> Self {
		var setForm = Self()
		setForm.store = store.symmetricDifference(other.store)
		return setForm
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

	mutating func formUnion(_ other: Self) {
		store.formUnion(other.store)
	}

	mutating func formSymmetricDifference(_ other: Self) {
		store.formSymmetricDifference(other.store)
	}

	mutating func formIntersection(_ other: Self) {
		store.formIntersection(other.store)
	}

	func toArray() -> [Element] {
		Array(store)
	}
}

private struct MySet<Element: DefaultsEnum.NativeType & Hashable>: SetForm, DefaultsEnum.SetAlgebraSerializable, DefaultsEnum.NativeType {
	var store: Set<Element>

	init() {
		self.store = []
	}

	init(_ elements: [Element]) {
		self.store = Set(elements)
	}
}

private struct CodableSet<Element: DefaultsEnum.Serializable & Codable & Hashable>: SetForm, DefaultsEnum.SetAlgebraSerializable, Codable {
	var store: Set<Element>

	init() {
		self.store = []
	}

	init(_ elements: [Element]) {
		self.store = Set(elements)
	}
}

private enum EnumForm: String {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

extension EnumForm: DefaultsEnum.NativeType {
	typealias CodableForm = CodableEnumForm
}

private enum CodableEnumForm: String {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

extension CodableEnumForm: DefaultsEnum.CodableType {
	typealias NativeForm = EnumForm
}

private func setCodable(forKey keyName: String, data: some Codable) {
	guard
		let text = try? JSONEncoder().encode(data),
		let string = String(data: text, encoding: .utf8)
	else {
		XCTAssert(false)
		return
	}

	UserDefaults.standard.set(string, forKey: keyName)
}

extension DefaultsEnum.Keys {
	fileprivate static let nativeArray = Key<[String]?>("arrayToNativeStaticArrayKey")
}

final class DefaultsMigrationTests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testDataToNativeData() {
		let answer = "Hello World!"
		let keyName = "dataToNativeData"
		let data = answer.data(using: .utf8)
		setCodable(forKey: keyName, data: data)
		let key = DefaultsEnum.Key<Data?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(answer, String(data: DefaultsEnum[key]!, encoding: .utf8))
		let newName = " Hank Chen"
		DefaultsEnum[key]?.append(newName.data(using: .utf8)!)
		XCTAssertEqual(answer + newName, String(data: DefaultsEnum[key]!, encoding: .utf8))
	}

	func testArrayDataToNativeCollectionData() {
		let answer = "Hello World!"
		let keyName = "arrayDataToNativeCollectionData"
		let data = answer.data(using: .utf8)
		setCodable(forKey: keyName, data: [data])
		let key = DefaultsEnum.Key<MyBag<Data>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(answer, String(data: DefaultsEnum[key]!.first!, encoding: .utf8))
		let newName = " Hank Chen"
		DefaultsEnum[key]?[0].append(newName.data(using: .utf8)!)
		XCTAssertEqual(answer + newName, String(data: DefaultsEnum[key]!.first!, encoding: .utf8))
	}

	func testArrayDataToCodableCollectionData() {
		let answer = "Hello World!"
		let keyName = "arrayDataToCodableCollectionData"
		let data = answer.data(using: .utf8)
		setCodable(forKey: keyName, data: CodableBag([data]))
		let key = DefaultsEnum.Key<CodableBag<Data>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(answer, String(data: DefaultsEnum[key]!.first!, encoding: .utf8))
		let newName = " Hank Chen"
		DefaultsEnum[key]?[0].append(newName.data(using: .utf8)!)
		XCTAssertEqual(answer + newName, String(data: DefaultsEnum[key]!.first!, encoding: .utf8))
	}

	func testArrayDataToNativeSetAlgebraData() {
		let answer = "Hello World!"
		let keyName = "arrayDataToNativeSetAlgebraData"
		let data = answer.data(using: .utf8)
		setCodable(forKey: keyName, data: CodableSet([data]))
		let key = DefaultsEnum.Key<CodableSet<Data>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(answer, String(data: DefaultsEnum[key]!.store.first!, encoding: .utf8))
		let newName = " Hank Chen"
		DefaultsEnum[key]?.store.insert(newName.data(using: .utf8)!)
		XCTAssertEqual(Set([answer.data(using: .utf8)!, newName.data(using: .utf8)!]), DefaultsEnum[key]?.store)
	}

	func testDateToNativeDate() {
		let date = Date()
		let keyName = "dateToNativeDate"
		setCodable(forKey: keyName, data: date)
		let key = DefaultsEnum.Key<Date?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(date, DefaultsEnum[key])
		let newDate = Date()
		DefaultsEnum[key] = newDate
		XCTAssertEqual(newDate, DefaultsEnum[key])
	}

	func testDateToNativeCollectionDate() {
		let date = Date()
		let keyName = "dateToNativeCollectionDate"
		setCodable(forKey: keyName, data: [date])
		let key = DefaultsEnum.Key<MyBag<Date>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(date, DefaultsEnum[key]!.first)
		let newDate = Date()
		DefaultsEnum[key]?[0] = newDate
		XCTAssertEqual(newDate, DefaultsEnum[key]!.first)
	}

	func testDateToCodableCollectionDate() {
		let date = Date()
		let keyName = "dateToCodableCollectionDate"
		setCodable(forKey: keyName, data: CodableBag([date]))
		let key = DefaultsEnum.Key<CodableBag<Date>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(date, DefaultsEnum[key]!.first)
		let newDate = Date()
		DefaultsEnum[key]?[0] = newDate
		XCTAssertEqual(newDate, DefaultsEnum[key]!.first)
	}

	func testBoolToNativeBool() {
		let bool = false
		let keyName = "boolToNativeBool"
		setCodable(forKey: keyName, data: bool)
		let key = DefaultsEnum.Key<Bool?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], bool)
		let newBool = true
		DefaultsEnum[key] = newBool
		XCTAssertEqual(DefaultsEnum[key], newBool)
	}

	func testBoolToNativeCollectionBool() {
		let bool = false
		let keyName = "boolToNativeCollectionBool"
		setCodable(forKey: keyName, data: [bool])
		let key = DefaultsEnum.Key<MyBag<Bool>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], bool)
		let newBool = true
		DefaultsEnum[key]?[0] = newBool
		XCTAssertEqual(DefaultsEnum[key]?[0], newBool)
	}

	func testBoolToCodableCollectionBool() {
		let bool = false
		let keyName = "boolToCodableCollectionBool"
		setCodable(forKey: keyName, data: CodableBag([bool]))
		let key = DefaultsEnum.Key<CodableBag<Bool>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], bool)
		let newBool = true
		DefaultsEnum[key]?[0] = newBool
		XCTAssertEqual(DefaultsEnum[key]?[0], newBool)
	}

	func testIntToNativeInt() {
		let int = Int.min
		let keyName = "intToNativeInt"
		setCodable(forKey: keyName, data: int)
		let key = DefaultsEnum.Key<Int?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], int)
		let newInt = Int.max
		DefaultsEnum[key] = newInt
		XCTAssertEqual(DefaultsEnum[key], newInt)
	}

	func testIntToNativeCollectionInt() {
		let int = Int.min
		let keyName = "intToNativeCollectionInt"
		setCodable(forKey: keyName, data: [int])
		let key = DefaultsEnum.Key<MyBag<Int>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int)
		let newInt = Int.max
		DefaultsEnum[key]?[0] = newInt
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt)
	}

	func testIntToCodableCollectionInt() {
		let int = Int.min
		let keyName = "intToCodableCollectionInt"
		setCodable(forKey: keyName, data: CodableBag([int]))
		let key = DefaultsEnum.Key<CodableBag<Int>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int)
		let newInt = Int.max
		DefaultsEnum[key]?[0] = newInt
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt)
	}

	func testUIntToNativeUInt() {
		let uInt = UInt.min
		let keyName = "uIntToNativeUInt"
		setCodable(forKey: keyName, data: uInt)
		let key = DefaultsEnum.Key<UInt?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], uInt)
		let newUInt = UInt.max
		DefaultsEnum[key] = newUInt
		XCTAssertEqual(DefaultsEnum[key], newUInt)
	}

	func testUIntToNativeCollectionUInt() {
		let uInt = UInt.min
		let keyName = "uIntToNativeCollectionUInt"
		setCodable(forKey: keyName, data: [uInt])
		let key = DefaultsEnum.Key<MyBag<UInt>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt)
		let newUInt = UInt.max
		DefaultsEnum[key]?[0] = newUInt
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt)
	}

	func testUIntToCodableCollectionUInt() {
		let uInt = UInt.min
		let keyName = "uIntToCodableCollectionUInt"
		setCodable(forKey: keyName, data: CodableBag([uInt]))
		let key = DefaultsEnum.Key<CodableBag<UInt>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt)
		let newUInt = UInt.max
		DefaultsEnum[key]?[0] = newUInt
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt)
	}

	func testDoubleToNativeDouble() {
		let double = Double.zero
		let keyName = "doubleToNativeDouble"
		setCodable(forKey: keyName, data: double)
		let key = DefaultsEnum.Key<Double?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], double)
		let newDouble = Double.infinity
		DefaultsEnum[key] = newDouble
		XCTAssertEqual(DefaultsEnum[key], newDouble)
	}

	func testDoubleToNativeCollectionDouble() {
		let double = Double.zero
		let keyName = "doubleToNativeCollectionDouble"
		setCodable(forKey: keyName, data: [double])
		let key = DefaultsEnum.Key<MyBag<Double>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], double)
		let newDouble = Double.infinity
		DefaultsEnum[key]?[0] = newDouble
		XCTAssertEqual(DefaultsEnum[key]?[0], newDouble)
	}

	func testDoubleToCodableCollectionDouble() {
		let double = Double.zero
		let keyName = "doubleToCodableCollectionDouble"
		setCodable(forKey: keyName, data: CodableBag([double]))
		let key = DefaultsEnum.Key<CodableBag<Double>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], double)
		let newDouble = Double.infinity
		DefaultsEnum[key]?[0] = newDouble
		XCTAssertEqual(DefaultsEnum[key]?[0], newDouble)
	}

	func testFloatToNativeFloat() {
		let float = Float.zero
		let keyName = "floatToNativeFloat"
		setCodable(forKey: keyName, data: float)
		let key = DefaultsEnum.Key<Float?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], float)
		let newFloat = Float.infinity
		DefaultsEnum[key] = newFloat
		XCTAssertEqual(DefaultsEnum[key], newFloat)
	}

	func testFloatToNativeCollectionFloat() {
		let float = Float.zero
		let keyName = "floatToNativeCollectionFloat"
		setCodable(forKey: keyName, data: [float])
		let key = DefaultsEnum.Key<MyBag<Float>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], float)
		let newFloat = Float.infinity
		DefaultsEnum[key]?[0] = newFloat
		XCTAssertEqual(DefaultsEnum[key]?[0], newFloat)
	}

	func testFloatToCodableCollectionFloat() {
		let float = Float.zero
		let keyName = "floatToCodableCollectionFloat"
		setCodable(forKey: keyName, data: CodableBag([float]))
		let key = DefaultsEnum.Key<CodableBag<Float>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], float)
		let newFloat = Float.infinity
		DefaultsEnum[key]?[0] = newFloat
		XCTAssertEqual(DefaultsEnum[key]?[0], newFloat)
	}

	func testCGFloatToNativeCGFloat() {
		let cgFloat = CGFloat.zero
		let keyName = "cgFloatToNativeCGFloat"
		setCodable(forKey: keyName, data: cgFloat)
		let key = DefaultsEnum.Key<CGFloat?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], cgFloat)
		let newCGFloat = CGFloat.infinity
		DefaultsEnum[key] = newCGFloat
		XCTAssertEqual(DefaultsEnum[key], newCGFloat)
	}

	func testCGFloatToNativeCollectionCGFloat() {
		let cgFloat = CGFloat.zero
		let keyName = "cgFloatToNativeCollectionCGFloat"
		setCodable(forKey: keyName, data: [cgFloat])
		let key = DefaultsEnum.Key<MyBag<CGFloat>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], cgFloat)
		let newCGFloat = CGFloat.infinity
		DefaultsEnum[key]?[0] = newCGFloat
		XCTAssertEqual(DefaultsEnum[key]?[0], newCGFloat)
	}

	func testCGFloatToCodableCollectionCGFloat() {
		let cgFloat = CGFloat.zero
		let keyName = "cgFloatToCodableCollectionCGFloat"
		setCodable(forKey: keyName, data: CodableBag([cgFloat]))
		let key = DefaultsEnum.Key<CodableBag<CGFloat>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], cgFloat)
		let newCGFloat = CGFloat.infinity
		DefaultsEnum[key]?[0] = newCGFloat
		XCTAssertEqual(DefaultsEnum[key]?[0], newCGFloat)
	}

	func testInt8ToNativeInt8() {
		let int8 = Int8.min
		let keyName = "int8ToNativeInt8"
		setCodable(forKey: keyName, data: int8)
		let key = DefaultsEnum.Key<Int8?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], int8)
		let newInt8 = Int8.max
		DefaultsEnum[key] = newInt8
		XCTAssertEqual(DefaultsEnum[key], newInt8)
	}

	func testInt8ToNativeCollectionInt8() {
		let int8 = Int8.min
		let keyName = "int8ToNativeCollectionInt8"
		setCodable(forKey: keyName, data: [int8])
		let key = DefaultsEnum.Key<MyBag<Int8>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int8)
		let newInt8 = Int8.max
		DefaultsEnum[key]?[0] = newInt8
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt8)
	}

	func testInt8ToCodableCollectionInt8() {
		let int8 = Int8.min
		let keyName = "int8ToCodableCollectionInt8"
		setCodable(forKey: keyName, data: CodableBag([int8]))
		let key = DefaultsEnum.Key<CodableBag<Int8>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int8)
		let newInt8 = Int8.max
		DefaultsEnum[key]?[0] = newInt8
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt8)
	}

	func testUInt8ToNativeUInt8() {
		let uInt8 = UInt8.min
		let keyName = "uInt8ToNativeUInt8"
		setCodable(forKey: keyName, data: uInt8)
		let key = DefaultsEnum.Key<UInt8?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], uInt8)
		let newUInt8 = UInt8.max
		DefaultsEnum[key] = newUInt8
		XCTAssertEqual(DefaultsEnum[key], newUInt8)
	}

	func testUInt8ToNativeCollectionUInt8() {
		let uInt8 = UInt8.min
		let keyName = "uInt8ToNativeCollectionUInt8"
		setCodable(forKey: keyName, data: [uInt8])
		let key = DefaultsEnum.Key<MyBag<UInt8>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt8)
		let newUInt8 = UInt8.max
		DefaultsEnum[key]?[0] = newUInt8
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt8)
	}

	func testUInt8ToCodableCollectionUInt8() {
		let uInt8 = UInt8.min
		let keyName = "uInt8ToCodableCollectionUInt8"
		setCodable(forKey: keyName, data: CodableBag([uInt8]))
		let key = DefaultsEnum.Key<CodableBag<UInt8>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt8)
		let newUInt8 = UInt8.max
		DefaultsEnum[key]?[0] = newUInt8
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt8)
	}

	func testInt16ToNativeInt16() {
		let int16 = Int16.min
		let keyName = "int16ToNativeInt16"
		setCodable(forKey: keyName, data: int16)
		let key = DefaultsEnum.Key<Int16?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], int16)
		let newInt16 = Int16.max
		DefaultsEnum[key] = newInt16
		XCTAssertEqual(DefaultsEnum[key], newInt16)
	}

	func testInt16ToNativeCollectionInt16() {
		let int16 = Int16.min
		let keyName = "int16ToNativeCollectionInt16"
		setCodable(forKey: keyName, data: [int16])
		let key = DefaultsEnum.Key<MyBag<Int16>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int16)
		let newInt16 = Int16.max
		DefaultsEnum[key]?[0] = newInt16
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt16)
	}

	func testInt16ToCodableCollectionInt16() {
		let int16 = Int16.min
		let keyName = "int16ToCodableCollectionInt16"
		setCodable(forKey: keyName, data: CodableBag([int16]))
		let key = DefaultsEnum.Key<CodableBag<Int16>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int16)
		let newInt16 = Int16.max
		DefaultsEnum[key]?[0] = newInt16
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt16)
	}

	func testUInt16ToNativeUInt16() {
		let uInt16 = UInt16.min
		let keyName = "uInt16ToNativeUInt16"
		setCodable(forKey: keyName, data: uInt16)
		let key = DefaultsEnum.Key<UInt16?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], uInt16)
		let newUInt16 = UInt16.max
		DefaultsEnum[key] = newUInt16
		XCTAssertEqual(DefaultsEnum[key], newUInt16)
	}

	func testUInt16ToNativeCollectionUInt16() {
		let uInt16 = UInt16.min
		let keyName = "uInt16ToNativeCollectionUInt16"
		setCodable(forKey: keyName, data: [uInt16])
		let key = DefaultsEnum.Key<MyBag<UInt16>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt16)
		let newUInt16 = UInt16.max
		DefaultsEnum[key]?[0] = newUInt16
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt16)
	}

	func testUInt16ToCodableCollectionUInt16() {
		let uInt16 = UInt16.min
		let keyName = "uInt16ToCodableCollectionUInt16"
		setCodable(forKey: keyName, data: CodableBag([uInt16]))
		let key = DefaultsEnum.Key<CodableBag<UInt16>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt16)
		let newUInt16 = UInt16.max
		DefaultsEnum[key]?[0] = newUInt16
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt16)
	}

	func testInt32ToNativeInt32() {
		let int32 = Int32.min
		let keyName = "int32ToNativeInt32"
		setCodable(forKey: keyName, data: int32)
		let key = DefaultsEnum.Key<Int32?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], int32)
		let newInt32 = Int32.max
		DefaultsEnum[key] = newInt32
		XCTAssertEqual(DefaultsEnum[key], newInt32)
	}

	func testInt32ToNativeCollectionInt32() {
		let int32 = Int32.min
		let keyName = "int32ToNativeCollectionInt32"
		setCodable(forKey: keyName, data: [int32])
		let key = DefaultsEnum.Key<MyBag<Int32>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int32)
		let newInt32 = Int32.max
		DefaultsEnum[key]?[0] = newInt32
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt32)
	}

	func testInt32ToCodableCollectionInt32() {
		let int32 = Int32.min
		let keyName = "int32ToCodableCollectionInt32"
		setCodable(forKey: keyName, data: CodableBag([int32]))
		let key = DefaultsEnum.Key<CodableBag<Int32>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int32)
		let newInt32 = Int32.max
		DefaultsEnum[key]?[0] = newInt32
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt32)
	}

	func testUInt32ToNativeUInt32() {
		let uInt32 = UInt32.min
		let keyName = "uInt32ToNativeUInt32"
		setCodable(forKey: keyName, data: uInt32)
		let key = DefaultsEnum.Key<UInt32?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], uInt32)
		let newUInt32 = UInt32.max
		DefaultsEnum[key] = newUInt32
		XCTAssertEqual(DefaultsEnum[key], newUInt32)
	}

	func testUInt32ToNativeCollectionUInt32() {
		let uInt32 = UInt32.min
		let keyName = "uInt32ToNativeCollectionUInt32"
		setCodable(forKey: keyName, data: [uInt32])
		let key = DefaultsEnum.Key<MyBag<UInt32>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt32)
		let newUInt32 = UInt32.max
		DefaultsEnum[key]?[0] = newUInt32
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt32)
	}

	func testUInt32ToCodableCollectionUInt32() {
		let uInt32 = UInt32.min
		let keyName = "uInt32ToCodableCollectionUInt32"
		setCodable(forKey: keyName, data: CodableBag([uInt32]))
		let key = DefaultsEnum.Key<CodableBag<UInt32>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt32)
		let newUInt32 = UInt32.max
		DefaultsEnum[key]?[0] = newUInt32
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt32)
	}

	func testInt64ToNativeInt64() {
		let int64 = Int64.min
		let keyName = "int64ToNativeInt64"
		setCodable(forKey: keyName, data: int64)
		let key = DefaultsEnum.Key<Int64?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], int64)
		let newInt64 = Int64.max
		DefaultsEnum[key] = newInt64
		XCTAssertEqual(DefaultsEnum[key], newInt64)
	}

	func testInt64ToNativeCollectionInt64() {
		let int64 = Int64.min
		let keyName = "int64ToNativeCollectionInt64"
		setCodable(forKey: keyName, data: [int64])
		let key = DefaultsEnum.Key<MyBag<Int64>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int64)
		let newInt64 = Int64.max
		DefaultsEnum[key]?[0] = newInt64
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt64)
	}

	func testInt64ToCodableCollectionInt64() {
		let int64 = Int64.min
		let keyName = "int64ToCodableCollectionInt64"
		setCodable(forKey: keyName, data: CodableBag([int64]))
		let key = DefaultsEnum.Key<CodableBag<Int64>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], int64)
		let newInt64 = Int64.max
		DefaultsEnum[key]?[0] = newInt64
		XCTAssertEqual(DefaultsEnum[key]?[0], newInt64)
	}

	func testUInt64ToNativeUInt64() {
		let uInt64 = UInt64.min
		let keyName = "uInt64ToNativeUInt64"
		setCodable(forKey: keyName, data: uInt64)
		let key = DefaultsEnum.Key<UInt64?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], uInt64)
		let newUInt64 = UInt64.max
		DefaultsEnum[key] = newUInt64
		XCTAssertEqual(DefaultsEnum[key], newUInt64)
	}

	func testUInt64ToNativeCollectionUInt64() {
		let uInt64 = UInt64.min
		let keyName = "uInt64ToNativeCollectionUInt64"
		setCodable(forKey: keyName, data: [uInt64])
		let key = DefaultsEnum.Key<MyBag<UInt64>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt64)
		let newUInt64 = UInt64.max
		DefaultsEnum[key]?[0] = newUInt64
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt64)
	}

	func testUInt64ToCodableCollectionUInt64() {
		let uInt64 = UInt64.min
		let keyName = "uInt64ToCodableCollectionUInt64"
		setCodable(forKey: keyName, data: CodableBag([uInt64]))
		let key = DefaultsEnum.Key<CodableBag<UInt64>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], uInt64)
		let newUInt64 = UInt64.max
		DefaultsEnum[key]?[0] = newUInt64
		XCTAssertEqual(DefaultsEnum[key]?[0], newUInt64)
	}

	func testArrayURLToNativeArrayURL() {
		let url = URL(string: "https://sindresorhus.com")!
		let keyName = "arrayURLToNativeArrayURL"
		setCodable(forKey: keyName, data: [url])
		let key = DefaultsEnum.Key<[URL]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], url)
		let newURL = URL(string: "https://example.com")!
		DefaultsEnum[key]?.append(newURL)
		XCTAssertEqual(DefaultsEnum[key]?[1], newURL)
	}

	func testArrayURLToNativeCollectionURL() {
		let url = URL(string: "https://sindresorhus.com")!
		let keyName = "arrayURLToNativeCollectionURL"
		setCodable(forKey: keyName, data: [url])
		let key = DefaultsEnum.Key<MyBag<URL>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], url)
		let newURL = URL(string: "https://example.com")!
		DefaultsEnum[key]?.insert(element: newURL, at: 1)
		XCTAssertEqual(DefaultsEnum[key]?[1], newURL)
	}

	func testArrayToNativeArray() {
		let keyName = "arrayToNativeArrayKey"
		setCodable(forKey: keyName, data: ["a", "b", "c"])
		let key = DefaultsEnum.Key<[String]>(keyName, default: [])
		DefaultsEnum.migrate(key, to: .v5)
		let newValue = "d"
		DefaultsEnum[key].append(newValue)
		XCTAssertEqual(DefaultsEnum[key][0], "a")
		XCTAssertEqual(DefaultsEnum[key][1], "b")
		XCTAssertEqual(DefaultsEnum[key][2], "c")
		XCTAssertEqual(DefaultsEnum[key][3], newValue)
	}

	func testArrayToNativeStaticOptionalArray() {
		let keyName = "arrayToNativeStaticArrayKey"
		setCodable(forKey: keyName, data: ["a", "b", "c"])
		DefaultsEnum.migrate(.nativeArray, to: .v5)
		let newValue = "d"
		DefaultsEnum[.nativeArray]?.append(newValue)
		XCTAssertEqual(DefaultsEnum[.nativeArray]?[0], "a")
		XCTAssertEqual(DefaultsEnum[.nativeArray]?[1], "b")
		XCTAssertEqual(DefaultsEnum[.nativeArray]?[2], "c")
		XCTAssertEqual(DefaultsEnum[.nativeArray]?[3], newValue)
	}

	func testArrayToNativeOptionalArray() {
		let keyName = "arrayToNativeArrayKey"
		setCodable(forKey: keyName, data: ["a", "b", "c"])
		let key = DefaultsEnum.Key<[String]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		let newValue = "d"
		DefaultsEnum[key]?.append(newValue)
		XCTAssertEqual(DefaultsEnum[key]?[0], "a")
		XCTAssertEqual(DefaultsEnum[key]?[1], "b")
		XCTAssertEqual(DefaultsEnum[key]?[2], "c")
		XCTAssertEqual(DefaultsEnum[key]?[3], newValue)
	}

	func testArrayDictionaryStringIntToNativeArray() {
		let keyName = "arrayDictionaryStringIntToNativeArray"
		setCodable(forKey: keyName, data: [["a": 0, "b": 1]])
		let key = DefaultsEnum.Key<[[String: Int]]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		let newValue = 2
		let newDictionary = ["d": 3]
		DefaultsEnum[key]?[0]["c"] = newValue
		DefaultsEnum[key]?.append(newDictionary)
		XCTAssertEqual(DefaultsEnum[key]?[0]["a"], 0)
		XCTAssertEqual(DefaultsEnum[key]?[0]["b"], 1)
		XCTAssertEqual(DefaultsEnum[key]?[0]["c"], newValue)
		XCTAssertEqual(DefaultsEnum[key]?[1]["d"], newDictionary["d"])
	}

	func testArrayToNativeSet() {
		let keyName = "arrayToNativeSet"
		setCodable(forKey: keyName, data: ["a", "b", "c"])
		let key = DefaultsEnum.Key<Set<String>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		let newValue = "d"
		DefaultsEnum[key]?.insert(newValue)
		XCTAssertEqual(DefaultsEnum[key], Set(["a", "b", "c", "d"]))
	}

	func testArrayToNativeCollectionType() {
		let string = "Hello World!"
		let keyName = "arrayToNativeCollectionType"
		setCodable(forKey: keyName, data: [string])
		let key = DefaultsEnum.Key<MyBag<String>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], string)
		let newString = "Hank Chen"
		DefaultsEnum[key]?[0] = newString
		XCTAssertEqual(DefaultsEnum[key]?[0], newString)
	}

	func testArrayToCodableCollectionType() {
		let keyName = "arrayToCodableCollectionType"
		setCodable(forKey: keyName, data: CodableBag(["a", "b", "c"]))
		let key = DefaultsEnum.Key<CodableBag<String>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		let newValue = "d"
		DefaultsEnum[key]?.insert(element: newValue, at: 3)
		XCTAssertEqual(DefaultsEnum[key]?[0], "a")
		XCTAssertEqual(DefaultsEnum[key]?[1], "b")
		XCTAssertEqual(DefaultsEnum[key]?[2], "c")
		XCTAssertEqual(DefaultsEnum[key]?[3], newValue)
	}

	func testArrayAndCodableElementToNativeCollectionType() {
		let keyName = "arrayAndCodableElementToNativeCollectionType"
		setCodable(forKey: keyName, data: [CodableTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<MyBag<TimeZone>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0].id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?.insert(element: .init(id: "1", name: newName), at: 1)
		XCTAssertEqual(DefaultsEnum[key]?[1].name, newName)
	}

	func testArrayAndCodableElementToNativeSetAlgebraType() {
		let keyName = "arrayAndCodableElementToNativeSetAlgebraType"
		setCodable(forKey: keyName, data: [CodableTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<MySet<TimeZone>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?.store.first?.id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?.insert(.init(id: "1", name: newName))
		XCTAssertEqual(Set([TimeZone(id: "0", name: "Asia/Taipei"), TimeZone(id: "1", name: newName)]), DefaultsEnum[key]?.store)
	}

	func testCodableToNativeType() {
		let keyName = "codableCodableToNativeType"
		setCodable(forKey: keyName, data: CodableTimeZone(id: "0", name: "Asia/Taipei"))
		let key = DefaultsEnum.Key<TimeZone>(keyName, default: .init(id: "1", name: "Asia/Tokio"))
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key].id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key].name = newName
		XCTAssertEqual(DefaultsEnum[key].name, newName)
	}

	func testCodableToNativeOptionalType() {
		let keyName = "codableCodableToNativeOptionalType"
		setCodable(forKey: keyName, data: CodableTimeZone(id: "0", name: "Asia/Taipei"))
		let key = DefaultsEnum.Key<TimeZone?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?.id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?.name = newName
		XCTAssertEqual(DefaultsEnum[key]?.name, newName)
	}

	func testArrayAndCodableElementToNativeArray() {
		let keyName = "codableArrayAndCodableElementToNativeArray"
		setCodable(forKey: keyName, data: [CodableTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<[TimeZone]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0].id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?[0].name = newName
		XCTAssertEqual(DefaultsEnum[key]?[0].name, newName)
	}

	func testArrayAndCodableElementToNativeSet() {
		let keyName = "arrayAndCodableElementToNativeSet"
		setCodable(forKey: keyName, data: [CodableTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<Set<TimeZone>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], Set([TimeZone(id: "0", name: "Asia/Taipei")]))
		let newId = "1"
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?.insert(.init(id: newId, name: newName))
		XCTAssertEqual(DefaultsEnum[key], Set([TimeZone(id: "0", name: "Asia/Taipei"), TimeZone(id: newId, name: newName)]))
	}

	func testCodableToNativeCodableOptionalType() {
		let keyName = "codableToNativeCodableOptionalType"
		setCodable(forKey: keyName, data: ChosenTimeZone(id: "0", name: "Asia/Taipei"))
		let key = DefaultsEnum.Key<ChosenTimeZone?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?.id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?.name = newName
		XCTAssertEqual(DefaultsEnum[key]?.name, newName)
	}

	func testCodableArrayToNativeCodableArrayType() {
		let keyName = "codableToNativeCodableArrayType"
		setCodable(forKey: keyName, data: [ChosenTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<[ChosenTimeZone]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0].id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?[0].name = newName
		XCTAssertEqual(DefaultsEnum[key]?[0].name, newName)
	}

	func testCodableArrayToNativeCollectionType() {
		let keyName = "codableToNativeCollectionType"
		setCodable(forKey: keyName, data: CodableBag([ChosenTimeZone(id: "0", name: "Asia/Taipei")]))
		let key = DefaultsEnum.Key<CodableBag<ChosenTimeZone>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0].id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?[0].name = newName
		XCTAssertEqual(DefaultsEnum[key]?[0].name, newName)
	}

	func testDictionaryToNativelyDictionary() {
		let keyName = "codableDictionaryToNativelyDictionary"
		setCodable(forKey: keyName, data: ["Hank": "Chen"])
		let key = DefaultsEnum.Key<[String: String]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?["Hank"], "Chen")
	}

	func testDictionaryAndCodableValueToNativeDictionary() {
		let keyName = "codableArrayAndCodableElementToNativeArray"
		setCodable(forKey: keyName, data: ["0": CodableTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<[String: TimeZone]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?["0"]?.id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?["0"]?.name = newName
		XCTAssertEqual(DefaultsEnum[key]?["0"]?.name, newName)
	}

	func testDictionaryCodableKeyAndCodableValueToNativeDictionary() {
		let keyName = "dictionaryCodableKeyAndCodableValueToNativeDictionary"
		setCodable(forKey: keyName, data: [123: CodableTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<[UInt32: TimeZone]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[123]?.id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?[123]?.name = newName
		XCTAssertEqual(DefaultsEnum[key]?[123]?.name, newName)
	}

	func testDictionaryCustomKeyAndCodableValueToNativeDictionary() {
		let keyName = "dictionaryCustomAndCodableValueToNativeDictionary"
		setCodable(forKey: keyName, data: [1234: CodableTimeZone(id: "0", name: "Asia/Taipei")])
		let key = DefaultsEnum.Key<[UniqueID: TimeZone]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		let id = UniqueID(id: 1234)
		XCTAssertEqual(DefaultsEnum[key]?[id]?.id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?[id]?.name = newName
		XCTAssertEqual(DefaultsEnum[key]?[id]?.name, newName)
	}

	func testNestedDictionaryCustomKeyAndCodableValueToNativeNestedDictionary() {
		let keyName = "nestedDictionaryCustomKeyAndCodableValueToNativeNestedDictionary"
		setCodable(forKey: keyName, data: [12_345: [1234: CodableTimeZone(id: "0", name: "Asia/Taipei")]])
		let key = DefaultsEnum.Key<[UniqueID: [UniqueID: TimeZone]]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		let firstId = UniqueID(id: 12_345)
		let secondId = UniqueID(id: 1234)
		XCTAssertEqual(DefaultsEnum[key]?[firstId]?[secondId]?.id, "0")
		let newName = "Asia/Tokyo"
		DefaultsEnum[key]?[firstId]?[secondId]?.name = newName
		XCTAssertEqual(DefaultsEnum[key]?[firstId]?[secondId]?.name, newName)
	}

	func testEnumToNativeEnum() {
		let keyName = "enumToNativeEnum"
		setCodable(forKey: keyName, data: CodableEnumForm.tenMinutes)
		let key = DefaultsEnum.Key<EnumForm?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key], .tenMinutes)
		DefaultsEnum[key] = .halfHour
		XCTAssertEqual(DefaultsEnum[key], .halfHour)
	}

	func testArrayEnumToNativeArrayEnum() {
		let keyName = "arrayEnumToNativeArrayEnum"
		setCodable(forKey: keyName, data: [CodableEnumForm.tenMinutes])
		let key = DefaultsEnum.Key<[EnumForm]?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?[0], .tenMinutes)
		DefaultsEnum[key]?.append(.halfHour)
		XCTAssertEqual(DefaultsEnum[key]?[1], .halfHour)
	}

	func testArrayEnumToNativeSetEnum() {
		let keyName = "arrayEnumToNativeSetEnum"
		setCodable(forKey: keyName, data: Set([CodableEnumForm.tenMinutes]))
		let key = DefaultsEnum.Key<Set<EnumForm>?>(keyName)
		DefaultsEnum.migrate(key, to: .v5)
		XCTAssertEqual(DefaultsEnum[key]?.first, .tenMinutes)
		DefaultsEnum[key]?.insert(.halfHour)
		XCTAssertEqual(DefaultsEnum[key], Set([.tenMinutes, .halfHour]))
	}
}
