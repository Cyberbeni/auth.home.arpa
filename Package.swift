// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
		.package(url: "https://codeberg.org/Cyberbeni/CBLogging", from: "1.3.2", traits: []),
		.package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.18.3"),
		.package(url: "https://github.com/hummingbird-community/hummingbird-elementary", from: "0.4.2"),
		.package(url: "https://github.com/elementary-swift/elementary-htmx", from: "0.5.1"),
		.package(url: "https://github.com/hummingbird-project/hummingbird-auth", from: "2.1.0"),
		.package(url: "https://github.com/vapor/jwt-kit", from: "5.3.0"),
		.package(url: "https://codeberg.org/Cyberbeni/LruCache", from: "1.1.1"),
		// Plugins:
		.package(url: "https://codeberg.org/Cyberbeni/SwiftFormat-mirror", from: "0.59.1"),
	],
	targets: [
		.executableTarget(
			name: "auth_home_arpa",
			dependencies: [
				.product(name: "CBLogging", package: "CBLogging"),
				.product(name: "Hummingbird", package: "hummingbird"),
				.product(name: "HummingbirdElementary", package: "hummingbird-elementary"),
				.product(name: "ElementaryHTMX", package: "elementary-htmx"),
				.product(name: "HummingbirdBcrypt", package: "hummingbird-auth"),
				.product(name: "JWTKit", package: "jwt-kit"),
				.product(name: "LruCache", package: "LruCache"),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
				.unsafeFlags(["-warnings-as-errors"], .when(configuration: .release)),
				.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-s"], .when(configuration: .release)), // STRIP_STYLE = all
			],
		),
	],
)
