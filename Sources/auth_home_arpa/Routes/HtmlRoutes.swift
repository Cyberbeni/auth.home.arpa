import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addUiRoutes(
		generalConfig: Config.General,
		staticFilesTimestamp: String,
		userService: UserService,
	) -> Self {
		let contentSecurityPolicy = "default-src 'self' 'unsafe-inline'"
		get("") { request, _ throws(Never) in
			let authToken: AuthToken?
			let invalidCookie: Bool
			if let cookie = request.cookies[Constants.cookieName] {
				authToken = await userService.authToken(cookie.value)
				invalidCookie = authToken == nil
			} else {
				authToken = nil
				invalidCookie = false
			}
			return HTMLResponse(additionalHeaders: [
				.cacheControl: CacheControl.privateNoCache,
				.contentSecurityPolicy: contentSecurityPolicy,
			]) {
				IndexPage(
					generalConfig: generalConfig,
					staticFilesTimestamp: staticFilesTimestamp,
					invalidCookie: invalidCookie,
					authToken: authToken,
					ip: request.headers[.xForwardedFor] ?? "unknown",
				)
			}
		}

		get("login.html") { _, _ throws(Never) in
			HTMLResponse(additionalHeaders: [
				.cacheControl: CacheControl.publicNoCache,
				.contentSecurityPolicy: contentSecurityPolicy,
			]) {
				LoginPage(
					generalConfig: generalConfig,
					staticFilesTimestamp: staticFilesTimestamp,
				)
			}
		}

		return self
	}
}
