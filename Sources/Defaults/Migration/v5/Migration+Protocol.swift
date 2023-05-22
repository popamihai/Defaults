import Foundation

/**
Only exists for migration.

Represents the type after migration and its protocol should conform to `DefaultsEnum.Serializable`.

It should have an associated type name `CodableForm` where its protocol conform to `Codable`.

So we can convert the JSON string into a `NativeType` like this:

```swift
guard
	let jsonData = string?.data(using: .utf8),
	let codable = try? JSONDecoder().decode(NativeType.CodableForm.self, from: jsonData)
else {
	return nil
}

return codable.toNative()
```
*/
public protocol _DefaultsNativeType: DefaultsEnum.Serializable {
	associatedtype CodableForm: DefaultsEnum.CodableType
}

/**
Only exists for migration.

Represents the type before migration an its protocol should conform to `Codable`.

The main purposed of `CodableType` is trying to infer the `Codable` type to do `JSONDecoder().decode`. It should have an associated type name `NativeForm` which is the type we want it to store in `UserDefaults`. nd it also have a `toNative()` function to convert itself into `NativeForm`.

```swift
struct User {
	username: String
	password: String
}

struct CodableUser: Codable {
	username: String
	password: String
}

extension User: DefaultsEnum.NativeType {
	typealias CodableForm = CodableUser
}

extension CodableUser: DefaultsEnum.CodableType {
	typealias NativeForm = User

	func toNative() -> NativeForm {
		User(username: self.username, password: self.password)
	}
}
```
*/
public protocol _DefaultsCodableType: Codable {
	associatedtype NativeForm: DefaultsEnum.NativeType
	func toNative() -> NativeForm
}
