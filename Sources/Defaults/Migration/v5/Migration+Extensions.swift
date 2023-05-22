import Foundation
import CoreGraphics

extension DefaultsEnum {
	public typealias NativeType = _DefaultsNativeType
	public typealias CodableType = _DefaultsCodableType
}

extension Data: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Data: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Date: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Date: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Bool: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Bool: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Int: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Int: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension UInt: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension UInt: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Double: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Double: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Float: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Float: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension String: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension String: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension CGFloat: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension CGFloat: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Int8: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Int8: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension UInt8: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension UInt8: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Int16: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Int16: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension UInt16: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension UInt16: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Int32: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Int32: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension UInt32: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension UInt32: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Int64: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension Int64: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension UInt64: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension UInt64: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension URL: DefaultsEnum.NativeType {
	public typealias CodableForm = Self
}

extension URL: DefaultsEnum.CodableType {
	public typealias NativeForm = Self

	public func toNative() -> Self { self }
}

extension Optional: DefaultsEnum.NativeType where Wrapped: DefaultsEnum.NativeType {
	public typealias CodableForm = Wrapped.CodableForm
}

extension DefaultsEnum.CollectionSerializable where Self: DefaultsEnum.NativeType, Element: DefaultsEnum.NativeType {
	public typealias CodableForm = [Element.CodableForm]
}

extension DefaultsEnum.SetAlgebraSerializable where Self: DefaultsEnum.NativeType, Element: DefaultsEnum.NativeType {
	public typealias CodableForm = [Element.CodableForm]
}

extension DefaultsEnum.CodableType where Self: RawRepresentable<NativeForm.RawValue>, NativeForm: RawRepresentable {
	public func toNative() -> NativeForm {
		NativeForm(rawValue: rawValue)!
	}
}

extension Set: DefaultsEnum.NativeType where Element: DefaultsEnum.NativeType {
	public typealias CodableForm = [Element.CodableForm]
}

extension Array: DefaultsEnum.NativeType where Element: DefaultsEnum.NativeType {
	public typealias CodableForm = [Element.CodableForm]
}

extension Array: DefaultsEnum.CodableType where Element: DefaultsEnum.CodableType {
	public typealias NativeForm = [Element.NativeForm]

	public func toNative() -> NativeForm {
		map { $0.toNative() }
	}
}

extension Dictionary: DefaultsEnum.NativeType where Key: LosslessStringConvertible & Hashable, Value: DefaultsEnum.NativeType {
	public typealias CodableForm = [String: Value.CodableForm]
}

extension Dictionary: DefaultsEnum.CodableType where Key == String, Value: DefaultsEnum.CodableType {
	public typealias NativeForm = [String: Value.NativeForm]

	public func toNative() -> NativeForm {
		reduce(into: NativeForm()) { memo, tuple in
			memo[tuple.key] = tuple.value.toNative()
		}
	}
}
