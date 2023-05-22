# Migration guide from v4 to v5

**Warning: Test the migration thoroughly in your app. It might cause unintended data loss if you're not careful.**

## Summary

We have improved the stored representation of types. Some types will require migration. Previously, all `Codable` types were serialized to a JSON string and stored as a `UserDefaults` string. `DefaultsEnum` is now able to store more types using the appropriate native `UserDefaults` type.

- The following types require no changes:
	- `Int(8/16/32/64)`
	- `UInt(8/16/32/64)`
	- `Double`
	- `CGFloat`
	- `Float`
	- `String`
	- `Bool`
	- `Date`
	- `Data`
	- `URL`
- Custom types (`struct`, `enum`, etc.) must now conform to `DefaultsEnum.Serializable` (in addition to `Codable`).
- `Array`, `Set`, and `Dictionary` will need to be manually migrated with `DefaultsEnum.migrate()`.

---

In v4, `DefaultsEnum` stored many types as a JSON string.\
In v5, `DefaultsEnum` stores many types as native `UserDefaults` types.

```swift
// v4
let key = DefaultsEnum.Key<[Int]>("key", default: [0, 1])

UserDefaults.standard.string(forKey: "key")
//=> "[0, 1]"
```

```swift
// v5
let key = DefaultsEnum.Key<[Int]>("key", default: [0, 1])

UserDefaults.standard.dictionary(forKey: "key")
//=> [0, 1]
```

## Issues

1. **The compiler complains that `DefaultsEnum.Key<Value>` does not conform to `DefaultsEnum.Serializable`.**
	Since we replaced `Codable` with `DefaultsEnum.Serializable`, `Key<Value>` will have to conform to `Value: DefaultsEnum.Serializable`.
	For this situation, please follow the guides below:
	- [From `Codable` struct in DefaultsEnum v4 to `Codable` struct in DefaultsEnum v5](#from-codable-struct-in-defaults-v4-to-codable-struct-in-defaults-v5)
	- [From `Codable` enum in DefaultsEnum v4 to `Codable` enum in DefaultsEnum v5](#from-codable-enum-in-defaults-v4-to-codable-enum-in-defaults-v5)

2. **The previous value in `UserDefaults` is not readable. (for example, `DefaultsEnum[.array]` returns `nil`).**
	In v5, `DefaultsEnum` reads value from `UserDefaults` as a natively supported type, but since `UserDefaults` only contains JSON string before migration for `Codable` types, `DefaultsEnum` will not be able to work with it. For this situation, `DefaultsEnum` provides the `DefaultsEnum.migrate()` method to automate the migration process.
	- [From `Codable` `Array/Dictionary/Set` in DefaultsEnum v4 to native `Array/Dictionary/Set`(with natively supported elements) in DefaultsEnum v5](#from-codable-arraydictionaryset-in-defaults-v4-to-native-arraydictionaryset-with-natively-supported-elements-in-defaults-v5)
	- [From `Codable` `Array/Dictionary/Set` in DefaultsEnum v4 to native `Array/Dictionary/Set` (with codable elements) in DefaultsEnum v5](#from-codable-arraydictionaryset-in-defaults-v4-to-native-arraydictionaryset-with-codable-elements-in-defaults-v5)

## Testing

We recommend doing some manual testing after migrating.

For example, let's say you are trying to migrate an array of `Codable` string to a native array.

1. Get the previous value in `UserDefaults` (using `defaults` command or whatever you want).

```swift
let string = "[\"a\",\"b\",\"c\"]"
```

2. Insert the above value into `UserDefaults`.

```swift
UserDefaults.standard.set(string, forKey: "testKey")
```

3. Call `DefaultsEnum.migrate()` and then use `DefaultsEnum` to get its value.

```swift
let key = DefaultsEnum.Key<[String]>("testKey", default: [])
DefaultsEnum.migrate(key, to: .v5)

DefaultsEnum[key] //=> [a, b, c]
```

## Migrations

### From `Codable` struct in DefaultsEnum v4 to `Codable` struct in DefaultsEnum v5

In v4, `struct` had to conform to `Codable` to store it as a JSON string.

In v5, `struct` has to conform to `Codable` and `DefaultsEnum.Serializable` to store it as a JSON string.

#### Before migration

```swift
private struct TimeZone: Codable {
	var id: String
	var name: String
}

extension DefaultsEnum.Keys {
	static let timezone = DefaultsEnum.Key<TimeZone?>("TimeZone")
}
```

#### Migration steps

1. Make `TimeZone` conform to `DefaultsEnum.Serializable`.

```swift
private struct TimeZone: Codable, DefaultsEnum.Serializable {
	var id: String
	var name: String
}
```

2. Now `DefaultsEnum[.timezone]` should be readable.

### From `Codable` enum in DefaultsEnum v4 to `Codable` enum in DefaultsEnum v5

In v4, `enum` had to conform to `Codable` to store it as a JSON string.

In v5, `enum` has to conform to `Codable` and `DefaultsEnum.Serializable` to store it as a JSON string.

#### Before migration

```swift
private enum Period: String, Codable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

extension DefaultsEnum.Keys {
	static let period = DefaultsEnum.Key<Period?>("period")
}
```

#### Migration steps

1. Make `Period` conform to `DefaultsEnum.Serializable`.

```swift
private enum Period: String, DefaultsEnum.Serializable, Codable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}
```

2. Now `DefaultsEnum[.period]` should be readable.

### From `Codable` `Array/Dictionary/Set` in DefaultsEnum v4 to native `Array/Dictionary/Set` (with natively supported elements) in DefaultsEnum v5

In v4, `DefaultsEnum` stored array/dictionary as a JSON string: `"[\"a\", \"b\", \"c\"]"`.

In v5, `DefaultsEnum` stores it as a native array/dictionary with natively supported elements: `["a", "b", "c"]`.

#### Before migration

```swift
extension DefaultsEnum.Keys {
	static let arrayString = DefaultsEnum.Key<[String]?>("arrayString")
	static let setString = DefaultsEnum.Key<Set<String>?>("setString")
	static let dictionaryStringInt = DefaultsEnum.Key<[String: Int]?>("dictionaryStringInt")
	static let dictionaryStringIntInArray = DefaultsEnum.Key<[[String: Int]]?>("dictionaryStringIntInArray")
}
```

#### Migration steps

1. **Call `DefaultsEnum.migrate(.arrayString, to: .v5)`, `DefaultsEnum.migrate(.setString, to: .v5)`, `DefaultsEnum.migrate(.dictionaryStringInt, to: .v5)`, `DefaultsEnum.migrate(.dictionaryStringIntInArray, to: .v5)`.**
2. Now `DefaultsEnum[.arrayString]`, `DefaultsEnum.[.setString]`, `DefaultsEnum[.dictionaryStringInt]`, `DefaultsEnum[.dictionaryStringIntInArray]` should be readable.

### From `Codable` `Array/Dictionary/Set` in DefaultsEnum v4 to native `Array/Dictionary/Set` (with `Codable` elements) in DefaultsEnum v5

In v4, `DefaultsEnum` would store array/dictionary as a single JSON string: `"{\"id\": \"0\", \"name\": \"Asia/Taipei\"}"`, `"[\"10 Minutes\", \"30 Minutes\"]"`.

In v5, `DefaultsEnum` will store it as a native array/dictionary with `Codable` elements: `{id: 0, name: "Asia/Taipei"}`, `["10 Minutes", "30 Minutes"]`.

#### Before migration

```swift
private struct TimeZone: Hashable, Codable {
	var id: String
	var name: String
}

private enum Period: String, Hashable, Codable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

extension DefaultsEnum.Keys {
	static let arrayTimezone = DefaultsEnum.Key<[TimeZone]?>("arrayTimezone")
	static let setTimezone = DefaultsEnum.Key<[TimeZone]?>("setTimezone")
	static let arrayPeriod = DefaultsEnum.Key<[Period]?>("arrayPeriod")
	static let setPeriod = DefaultsEnum.Key<[Period]?>("setPeriod")
	static let dictionaryTimezone = DefaultsEnum.Key<[String: TimeZone]?>("dictionaryTimezone")
	static let dictionaryPeriod = DefaultsEnum.Key<[String: Period]?>("dictionaryPeriod")
}
```

#### Migration steps

1. Make `TimeZone` and `Period` conform to `DefaultsEnum.Serializable`.

```swift
private struct TimeZone: Hashable, Codable, DefaultsEnum.Serializable {
	var id: String
	var name: String
}

private enum Period: String, Hashable, Codable, DefaultsEnum.Serializable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}
```

2. **Call `DefaultsEnum.migrate(.arrayTimezone, to: .v5)`, `DefaultsEnum.migrate(.setTimezone, to: .v5)`, `DefaultsEnum.migrate(.dictionaryTimezone, to: .v5)`, `DefaultsEnum.migrate(.arrayPeriod, to: .v5)`, `DefaultsEnum.migrate(.setPeriod, to: .v5)` , `DefaultsEnum.migrate(.dictionaryPeriod, to: .v5)`.**
3. Now `DefaultsEnum[.arrayTimezone]`, `DefaultsEnum[.setTimezone]`, `DefaultsEnum[.dictionaryTimezone]`, `DefaultsEnum[.arrayPeriod]`, `DefaultsEnum[.setPeriod]` , `DefaultsEnum[.dictionaryPeriod]` should be readable.

---

## Optional migrations

### From `Codable` enum in DefaultsEnum v4 to `RawRepresentable` enum in DefaultsEnum v5 *(Optional)*

In v4, `DefaultsEnum` will store `enum` as a JSON string: `"10 Minutes"`.

In v5, `DefaultsEnum` can store `enum` as a native string: `10 Minutes`.

#### Before migration

```swift
private enum Period: String, Codable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

extension DefaultsEnum.Keys {
	static let period = DefaultsEnum.Key<Period?>("period")
}
```

#### Migration steps

1. Create another enum called `CodablePeriod` and create an extension of it. Make the extension conform to `DefaultsEnum.CodableType` and its associated type `NativeForm` to `Period`.

```swift
private enum CodablePeriod: String {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

extension CodablePeriod: DefaultsEnum.CodableType {
	typealias NativeForm = Period
}
```

2. Remove `Codable` conformance so `Period` can be stored natively.

```swift
private enum Period: String {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}
```

3. Create an extension of `Period` that conforms to `DefaultsEnum.NativeType`. Its `CodableForm` should be `CodablePeriod`.

```swift
extension Period: DefaultsEnum.NativeType {
	typealias CodableForm = CodablePeriod
}
```

4. **Call `DefaultsEnum.migrate(.period)`**
5. Now `DefaultsEnum[.period]` should be readable.

You can also instead implement the `toNative` function in `DefaultsEnum.CodableType` for flexibility:

```swift
extension CodablePeriod: DefaultsEnum.CodableType {
	typealias NativeForm = Period

	public func toNative() -> Period {
		switch self {
		case .tenMinutes:
			return .tenMinutes
		case .halfHour:
			return .halfHour
		case .oneHour:
			return .oneHour
		}
	}
}
```

### From `Codable` struct in DefaultsEnum v4 to `Dictionary` in DefaultsEnum v5 *(Optional)*

This happens when you have a struct which is stored as a `Codable` JSON string before, but now you want it to be stored as a native `UserDefaults` dictionary.

#### Before migration

```swift
private struct TimeZone: Codable {
	var id: String
	var name: String
}

extension DefaultsEnum.Keys {
	static let timezone = DefaultsEnum.Key<TimeZone?>("TimeZone")
	static let arrayTimezone = DefaultsEnum.Key<[TimeZone]?>("arrayTimezone")
	static let setTimezone = DefaultsEnum.Key<Set<TimeZone>?>("setTimezone")
	static let dictionaryTimezone = DefaultsEnum.Key<[String: TimeZone]?>("setTimezone")
}
```

#### Migration steps

1. Create a `TimeZoneBridge` which conforms to `DefaultsEnum.Bridge` and its `Value` is `TimeZone` and `Serializable` is `[String: String]`.

```swift
private struct TimeZoneBridge: DefaultsEnum.Bridge {
	typealias Value = TimeZone
	typealias Serializable = [String: String]

	func serialize(_ value: TimeZone?) -> Serializable? {
		guard let value else {
			return nil
		}

		return [
			"id": value.id,
			"name": value.name
		]
	}

	func deserialize(_ object: Serializable?) -> TimeZone? {
		guard
			let object,
			let id = object["id"],
			let name = object["name"]
		else {
			return nil
		}

		return TimeZone(
			id: id,
			name: name
		)
	}
}
```

2. Create an extension of `TimeZone` that conforms to `DefaultsEnum.NativeType` and its static bridge is `TimeZoneBridge`. The compiler will complain that `TimeZone` does not conform to `DefaultsEnum.NativeType`. We will resolve that later.

```swift
private struct TimeZone: Hashable {
	var id: String
	var name: String
}

extension TimeZone: DefaultsEnum.NativeType {
	static let bridge = TimeZoneBridge()
}
```

3. Create an extension of `CodableTimeZone` that conforms to `DefaultsEnum.CodableType`.

```swift
private struct CodableTimeZone {
	var id: String
	var name: String
}

extension CodableTimeZone: DefaultsEnum.CodableType {
	/**
	Convert from `Codable` to native type.
	*/
	func toNative() -> TimeZone {
		TimeZone(id: id, name: name)
	}
}
```

4. Associate `TimeZone.CodableForm` to `CodableTimeZone`

```swift
extension TimeZone: DefaultsEnum.NativeType {
	typealias CodableForm = CodableTimeZone

	static let bridge = TimeZoneBridge()
}
```

5. **Call `DefaultsEnum.migrate(.timezone, to: .v5)`, `DefaultsEnum.migrate(.arrayTimezone, to: .v5)`, `DefaultsEnum.migrate(.setTimezone, to: .v5)`, `DefaultsEnum.migrate(.dictionaryTimezone, to: .v5)`**.
6. Now `DefaultsEnum[.timezone]`, `DefaultsEnum[.arrayTimezone]` , `DefaultsEnum[.setTimezone]`, `DefaultsEnum[.dictionaryTimezone]` should be readable.

**See [DefaultsMigrationTests.swift](./Tests/DefaultsTests/DefaultsMigrationTests.swift) for more example.**
