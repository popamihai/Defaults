import Foundation

extension DefaultsEnum {
	/**
	Reset the given string keys back to their default values.

	Prefer using the strongly-typed keys instead whenever possible. This method can be useful if you need to store some keys in a collection, as it's not possible to store `DefaultsEnum.Key` in a collection because it's generic.

	- Parameter keys: String keys to reset.
	- Parameter suite: `UserDefaults` suite.

	```swift
	extension DefaultsEnum.Keys {
		static let isUnicornMode = Key<Bool>("isUnicornMode", default: false)
	}

	DefaultsEnum[.isUnicornMode] = true
	//=> true

	DefaultsEnum.reset(DefaultsEnum.Keys.isUnicornMode.name)
	// Or `DefaultsEnum.reset("isUnicornMode")`

	DefaultsEnum[.isUnicornMode]
	//=> false
	```
	*/
	public static func reset(_ keys: String..., suite: UserDefaults = .standard) {
		reset(keys, suite: suite)
	}

	/**
	Reset the given string keys back to their default values.

	Prefer using the strongly-typed keys instead whenever possible. This method can be useful if you need to store some keys in a collection, as it's not possible to store `DefaultsEnum.Key` in a collection because it's generic.

	- Parameter keys: String keys to reset.
	- Parameter suite: `UserDefaults` suite.

	```swift
	extension DefaultsEnum.Keys {
		static let isUnicornMode = Key<Bool>("isUnicornMode", default: false)
	}

	DefaultsEnum[.isUnicornMode] = true
	//=> true

	DefaultsEnum.reset([DefaultsEnum.Keys.isUnicornMode.name])
	// Or `DefaultsEnum.reset(["isUnicornMode"])`

	DefaultsEnum[.isUnicornMode]
	//=> false
	```
	*/
	public static func reset(_ keys: [String], suite: UserDefaults = .standard) {
		for key in keys {
			suite.removeObject(forKey: key)
		}
	}
}

extension DefaultsEnum {
	/**
	Reset the given keys back to their default values.

	```swift
	extension DefaultsEnum.Keys {
		static let isUnicornMode = Key<Bool>("isUnicornMode", default: false)
	}

	DefaultsEnum[.isUnicornMode] = true
	//=> true

	DefaultsEnum.reset(.isUnicornMode)

	DefaultsEnum[.isUnicornMode]
	//=> false
	```
	*/
	public static func reset(_ keys: _AnyKey...) {
		reset(keys)
	}

	/**
	Reset the given keys back to their default values.

	```swift
	extension DefaultsEnum.Keys {
		static let isUnicornMode = Key<Bool>("isUnicornMode", default: false)
	}

	DefaultsEnum[.isUnicornMode] = true
	//=> true

	DefaultsEnum.reset(.isUnicornMode)

	DefaultsEnum[.isUnicornMode]
	//=> false
	```
	*/
	public static func reset(_ keys: [_AnyKey]) {
		for key in keys {
			key.reset()
		}
	}
}
