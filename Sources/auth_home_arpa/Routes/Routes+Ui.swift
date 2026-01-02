import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addUiRoutes(staticFilesTimestamp: String) -> Self {
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
