import Hummingbird
import ServiceLifecycle

actor App {
	let configDir: URL
	let socketPath: String

	static func responseJsonEncoder() -> JSONEncoder {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}

	init() {
		configDir = URL(filePath: "/config")
		socketPath = "/socket/auth.socket"
	}

	func run() async throws {
		// TODO: Parse config

		// TODO: Setup services

		// Setup Application
		let router = Router()

		router
			.addForwardAuthRoutes()
			.addUiRoutes()

		let app = Application(
			router: router,
			configuration: ApplicationConfiguration(address: .unixDomainSocket(path: socketPath)),
			services: [],
			onServerRunning: { _ in
				Log.info("Server running")
			}
		)

		try await app.runService()
	}
}
