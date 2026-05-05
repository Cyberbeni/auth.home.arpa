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
		let generalConfig: Config.General
		let userConfig: Config.User

		do {
			generalConfig = try decoder.decode(
				Config.General.self,
				from: Data(contentsOf: configDir.appending(component: "config.general.json")),
			)
		} catch {
			generalConfig = .default
		}

		do {
			userConfig = try decoder.decode(
				Config.User.self,
				from: Data(contentsOf: configDir.appending(component: "config.user.json")),
			)
		} catch {
			Log.error("Error parsing config.user.json: \(error)")
			return
		}

		// Setup services
		await AuthToken.setupKeys(secret: generalConfig.secret)
		let userService = UserService(
			generalConfig: generalConfig,
			userConfig: userConfig,
		)

		// Setup Application
		let router = Router()

		router
			.addHashPasswordRoute()
			.addForwardAuthRoute(userService: userService)
			.addLoginRoute(
				generalConfig: generalConfig,
				userService: userService,
			)
			.addUiRoutes(
				staticFilesTimestamp: staticFilesTimestamp,
				userService: userService,
			)

		router
			.add(middleware: FileMiddleware("/data/public", urlBasePath: "/" + staticFilesTimestamp, cacheControl: .init([
				(MediaType(type: .any), .publicImmutable),
			])))

		do {
			try FileManager.default.removeItem(atPath: socketPath)
		} catch {
			Log.debug("Failed to remove old socket: \(error)")
		}
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
