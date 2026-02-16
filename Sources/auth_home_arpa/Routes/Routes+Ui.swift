import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addUiRoutes(
		staticFilesTimestamp: String,
		userService: UserService,
	) -> Self {
		get("") { request, _ in
			let authToken: AuthToken?
			if let cookie = request.cookies[Constants.cookieName] {
				authToken = await userService.authToken(cookie.value)
			} else {
				authToken = nil
			}
			return HTMLResponse {
				ProfilePage(
					staticFilesTimestamp: staticFilesTimestamp,
					authToken: authToken,
					ip: request.headers[.xForwardedFor] ?? "unknown",
				)
			}
		}

		get("login.html") { _, _ in
			HTMLResponse {
				LoginPage(
					staticFilesTimestamp: staticFilesTimestamp,
				)
			}
		}

		return self
	}
}
