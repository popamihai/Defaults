import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DefaultsEnum.Serializable {
	public static var isNativelySupportedType: Bool { false }
}

extension Data: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Date: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Bool: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Int: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Double: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Float: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension String: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension CGFloat: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Int8: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt8: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Int16: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt16: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Int32: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt32: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension Int64: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt64: DefaultsEnum.Serializable {
	public static let isNativelySupportedType = true
}

extension URL: DefaultsEnum.Serializable {
	public static let bridge = DefaultsEnum.URLBridge()
}

extension DefaultsEnum.Serializable where Self: Codable {
	public static var bridge: DefaultsEnum.TopLevelCodableBridge<Self> { DefaultsEnum.TopLevelCodableBridge() }
}

extension DefaultsEnum.Serializable where Self: Codable & NSSecureCoding & NSObject {
	public static var bridge: DefaultsEnum.CodableNSSecureCodingBridge<Self> { DefaultsEnum.CodableNSSecureCodingBridge() }
}

extension DefaultsEnum.Serializable where Self: Codable & NSSecureCoding & NSObject & DefaultsEnum.PreferNSSecureCoding {
	public static var bridge: DefaultsEnum.NSSecureCodingBridge<Self> { DefaultsEnum.NSSecureCodingBridge() }
}

extension DefaultsEnum.Serializable where Self: Codable & RawRepresentable {
	public static var bridge: DefaultsEnum.RawRepresentableCodableBridge<Self> { DefaultsEnum.RawRepresentableCodableBridge() }
}

extension DefaultsEnum.Serializable where Self: Codable & RawRepresentable & DefaultsEnum.PreferRawRepresentable {
	public static var bridge: DefaultsEnum.RawRepresentableBridge<Self> { DefaultsEnum.RawRepresentableBridge() }
}

extension DefaultsEnum.Serializable where Self: RawRepresentable {
	public static var bridge: DefaultsEnum.RawRepresentableBridge<Self> { DefaultsEnum.RawRepresentableBridge() }
}

extension DefaultsEnum.Serializable where Self: NSSecureCoding & NSObject {
	public static var bridge: DefaultsEnum.NSSecureCodingBridge<Self> { DefaultsEnum.NSSecureCodingBridge() }
}

extension Optional: DefaultsEnum.Serializable where Wrapped: DefaultsEnum.Serializable {
	public static var isNativelySupportedType: Bool { Wrapped.isNativelySupportedType }
	public static var bridge: DefaultsEnum.OptionalBridge<Wrapped> { DefaultsEnum.OptionalBridge() }
}

extension DefaultsEnum.CollectionSerializable where Element: DefaultsEnum.Serializable {
	public static var bridge: DefaultsEnum.CollectionBridge<Self> { DefaultsEnum.CollectionBridge() }
}

extension DefaultsEnum.SetAlgebraSerializable where Element: DefaultsEnum.Serializable & Hashable {
	public static var bridge: DefaultsEnum.SetAlgebraBridge<Self> { DefaultsEnum.SetAlgebraBridge() }
}

extension Set: DefaultsEnum.Serializable where Element: DefaultsEnum.Serializable {
	public static var bridge: DefaultsEnum.SetBridge<Element> { DefaultsEnum.SetBridge() }
}

extension Array: DefaultsEnum.Serializable where Element: DefaultsEnum.Serializable {
	public static var isNativelySupportedType: Bool { Element.isNativelySupportedType }
	public static var bridge: DefaultsEnum.ArrayBridge<Element> { DefaultsEnum.ArrayBridge() }
}

extension Dictionary: DefaultsEnum.Serializable where Key: LosslessStringConvertible & Hashable, Value: DefaultsEnum.Serializable {
	public static var isNativelySupportedType: Bool { Value.isNativelySupportedType }
	public static var bridge: DefaultsEnum.DictionaryBridge<Key, Value> { DefaultsEnum.DictionaryBridge() }
}

extension UUID: DefaultsEnum.Serializable {
	public static let bridge = DefaultsEnum.UUIDBridge()
}

@available(iOS 15.0, macOS 11.0, tvOS 15.0, watchOS 8.0, iOSApplicationExtension 15.0, macOSApplicationExtension 11.0, tvOSApplicationExtension 15.0, watchOSApplicationExtension 8.0, *)
extension Color: DefaultsEnum.Serializable {
	public static let bridge = DefaultsEnum.ColorBridge()
}

extension Range: DefaultsEnum.RangeSerializable where Bound: DefaultsEnum.Serializable {
	public static var bridge: DefaultsEnum.RangeBridge<Range> { DefaultsEnum.RangeBridge() }
}

extension ClosedRange: DefaultsEnum.RangeSerializable where Bound: DefaultsEnum.Serializable {
	public static var bridge: DefaultsEnum.RangeBridge<ClosedRange> { DefaultsEnum.RangeBridge() }
}

#if os(macOS)
/**
`NSColor` conforms to `NSSecureCoding`, so it goes to `NSSecureCodingBridge`.
*/
extension NSColor: DefaultsEnum.Serializable {}
#else
/**
`UIColor` conforms to `NSSecureCoding`, so it goes to `NSSecureCodingBridge`.
*/
extension UIColor: DefaultsEnum.Serializable {}
#endif
