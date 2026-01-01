import CBLogging
@_exported import Foundation

var Log: Logger { CBLogHandler.appLogger }

@main
@MainActor
class Entrypoint {
	static func main() async throws {
		#if DEBUG
			CBLogHandler.bootstrap(defaultLogLevel: .info, appLogLevel: .debug)
		#else
			CBLogHandler.bootstrap(defaultLogLevel: .notice, appLogLevel: .info)
		#endif

		let app = App()
		try await app.run()
	}
}
