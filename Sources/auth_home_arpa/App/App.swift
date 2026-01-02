import Hummingbird
import ServiceLifecycle

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
		let userConfig: Config.User

		do {
			userConfig = try decoder.decode(
				Config.User.self,
				from: Data(contentsOf: configDir.appending(component: "config.user.json"))
			)
		} catch {
			Log.error("Error parsing config.users.json: \(error)")
			return
		}

		// Setup services
		let userService = UserService(userConfig: userConfig)

		// Setup Application
		let router = Router()

		router
			.addForwardAuthRoutes(userService: userService)
			.addLoginRoutes(userService: userService)
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
