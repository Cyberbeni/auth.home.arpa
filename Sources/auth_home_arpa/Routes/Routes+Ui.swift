import Hummingbird
import HummingbirdElementary

extension Router {
	@discardableResult
	func addUiRoutes() -> Self {
		get("login.html") { _, _ in
			HTMLResponse {
				LoginPage()
			}
		}

		return self
	}
}
