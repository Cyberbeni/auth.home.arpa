// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if canImport(Glibc)
let extraLinkerSettings: [LinkerSetting] = [
	.unsafeFlags(["-lcrypt"])
]
#else
let extraLinkerSettings: [LinkerSetting] = []
#endif

let package = Package(
	name: "auth_home_arpa",
	platforms: [.macOS(.v26)],
	products: [
		.executable(
			name: "auth_home_arpa",
			targets: ["auth_home_arpa"],
		),
	],
	dependencies: [
		.package(url: "https://github.com/Cyberbeni/CBLogging", from: "1.3.1"),
		.package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.18.3"),
		.package(url: "https://github.com/hummingbird-community/hummingbird-elementary", from: "0.4.2"),
		.package(url: "https://github.com/sliemeobn/elementary-htmx", from: "0.5.1"),
		// Plugins:
		.package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.58.7"),
	],
	targets: [
		.executableTarget(
			name: "auth_home_arpa",
			dependencies: [
				.product(name: "CBLogging", package: "CBLogging"),
				.product(name: "Hummingbird", package: "hummingbird"),
				.product(name: "HummingbirdElementary", package: "hummingbird-elementary"),
				.product(name: "ElementaryHTMX", package: "elementary-htmx"),
			],
			swiftSettings: [
				.unsafeFlags(["-warnings-as-errors"], .when(configuration: .release)),
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-s"], .when(configuration: .release)), // STRIP_STYLE = all
			] + extraLinkerSettings,
		),
	],
)
