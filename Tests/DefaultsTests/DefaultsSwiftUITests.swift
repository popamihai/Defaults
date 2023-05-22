import XCTest
import Foundation
import SwiftUI
import Defaults

#if os(macOS)
typealias NativeColor = NSColor
#else
typealias NativeColor = UIColor
#endif

@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension DefaultsEnum.Keys {
	fileprivate static let hasUnicorn = Key<Bool>("swiftui_hasUnicorn", default: false)
	fileprivate static let user = Key<User>("swiftui_user", default: User(username: "Hank", password: "123456"))
	fileprivate static let setInt = Key<Set<Int>>("swiftui_setInt", default: Set(1...3))
	fileprivate static let color = Key<Color>("swiftui_color", default: .black)
}

@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
struct ContentView: View {
	@Default(.hasUnicorn) var hasUnicorn
	@Default(.user) var user
	@Default(.setInt) var setInt
	@Default(.color) var color

	var body: some View {
		Text("User \(user.username) has Unicorn: \(String(hasUnicorn))")
			.foregroundColor(color)
		Toggle("Toggle Unicorn", isOn: $hasUnicorn)
	}
}

@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class DefaultsSwiftUITests: XCTestCase {
	override func setUp() {
		super.setUp()
		DefaultsEnum.removeAll()
	}

	override func tearDown() {
		super.tearDown()
		DefaultsEnum.removeAll()
	}

	func testSwiftUIObserve() {
		let view = ContentView()
		XCTAssertFalse(view.hasUnicorn)
		XCTAssertEqual(view.user.username, "Hank")
		XCTAssertEqual(view.setInt.count, 3)
		XCTAssertEqual(NativeColor(view.color), NativeColor(Color.black))
		view.user = User(username: "Chen", password: "123456")
		view.hasUnicorn.toggle()
		view.setInt.insert(4)
		view.color = Color(.sRGB, red: 100, green: 100, blue: 100, opacity: 1)
		XCTAssertTrue(view.hasUnicorn)
		XCTAssertEqual(view.user.username, "Chen")
		XCTAssertEqual(view.setInt, Set(1...4))
		XCTAssertFalse(Default(.hasUnicorn).defaultValue)
		XCTAssertFalse(Default(.hasUnicorn).isDefaultValue)
		XCTAssertNotEqual(NativeColor(view.color), NativeColor(Color.black))
		XCTAssertEqual(NativeColor(view.color), NativeColor(Color(.sRGB, red: 100, green: 100, blue: 100, opacity: 1)))
	}
}
