import Hummingbird

extension Router {
	@discardableResult
	func addForwardAuthRoutes() -> Self {
		get("api/auth") { _, _ in
			// TODO: check credentials
			Response(
				status: .noContent
			)
		}

		return self
	}
}
