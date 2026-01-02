import Hummingbird
import ServiceLifecycle
#if canImport(Musl)
import Musl
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

actor App {
	let configDir: URL
	let socketPath: String
	let staticFilesTimestamp: String

	static func responseJsonEncoder() -> JSONEncoder {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}

	init() throws {
		configDir = URL(filePath: "/config")
		socketPath = "/socket/auth.sock"
		staticFilesTimestamp = try String(contentsOfFile: "/data/static_files_timestamp", encoding: .utf8)
	}

	func run() async throws {
		// Parse config
		let decoder = Config.jsonDecoder()
		let usersConfig: Config.Users

		do {
			usersConfig = try decoder.decode(
				Config.Users.self,
				from: Data(contentsOf: configDir.appending(component: "config.users.json"))
			)
		} catch {
			Log.error("Error parsing config.users.json: \(error)")
			return
		}

		for (_, password) in usersConfig.users {
			let result = crypt("admin", password).map { String(cString: $0) }
			Log.info("crypt result: \(result ?? "-")")
		}

		// TODO: Setup services

		// Setup Application
		let router = Router()

		router
			.addForwardAuthRoutes()
			.addLoginRoutes()
			.addUiRoutes(staticFilesTimestamp: staticFilesTimestamp)

		router
			.add(middleware: FileMiddleware("/data/public", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
				(MediaType(type: .any), .publicImmutable),
			])))

		let app = Application(
			router: router,
			configuration: ApplicationConfiguration(address: .unixDomainSocket(path: socketPath)),
			services: [],
			onServerRunning: { _ in
				Log.info("Server running")
			},
		)

		try await app.runService()
	}
}
