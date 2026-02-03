import CBLogging
#if canImport(FoundationEssentials)
	@_exported import FoundationEssentials
#else
	@_exported import Foundation
#endif
#if canImport(Musl)
	@_exported import Musl
#elseif canImport(Glibc)
	@_exported import Glibc
#elseif canImport(Darwin)
	@_exported import Darwin
#endif

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

		let app = try App()
		try await app.run()
	}
}
