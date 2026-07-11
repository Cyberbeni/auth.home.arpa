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
		.package(url: "https://codeberg.org/Cyberbeni/CBLogging", from: "1.4.2"),
		.package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.25.0"),
		.package(url: "https://github.com/hummingbird-community/hummingbird-elementary", from: "0.5.1"),
		.package(url: "https://github.com/elementary-swift/elementary-htmx", from: "0.5.1"),
		.package(url: "https://github.com/hummingbird-project/hummingbird-auth", from: "2.2.0"),
		.package(url: "https://github.com/vapor/jwt-kit", from: "5.5.0"),
		.package(id: "Cyberbeni.LruCache", from: "1.1.3"),
		// Plugins:
		.package(url: "https://codeberg.org/Cyberbeni/SwiftFormat-mirror", from: "0.60.1"),
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
				.product(name: "LruCache", package: "Cyberbeni.LruCache"),
				.targetItem(name: "Foundation", condition: .when(platforms: [.linux])),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
				.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-s"], .when(configuration: .release)), // STRIP_STYLE = all
			],
		),
		.target(name: "Foundation"),
	],
)
