import Hummingbird

extension Router {
	@discardableResult
	func addForwardAuthRoute(userService: UserService) -> Self {
		get("api/auth") { request, _ in
			guard let ip = request.headers[.xForwardedFor] else {
				return Response(
					status: .badRequest,
				)
			}
			if let cookie = request.cookies[Constants.cookieName],
			   await userService.checkCookie(cookie.value, ip: ip)
			{
				return Response(
					status: .noContent,
				)
			} else {
				guard
					let redirectString = request.uri.queryParameters["redirect"],
					let redirectUrlBase = URL(string: String(redirectString)),
					var components = URLComponents(url: redirectUrlBase, resolvingAgainstBaseURL: false),
					let forwardedProto = request.headers[.xForwardedProto],
					let forwardedHost = request.headers[.xForwardedHost],
					let forwardedUri = request.headers[.xForwardedUri]
				else {
					return Response(
						status: .badRequest,
					)
				}
				components.path = "/login.html"
				components.queryItems = [.init(name: "redirect", value: "\(forwardedProto)://\(forwardedHost)\(forwardedUri)")]
				guard let redirectUrl = components.url?.absoluteString else {
					return Response(
						status: .internalServerError,
					)
				}
				return Response(
					status: .found,
					headers: HTTPFields(dictionaryLiteral: (.location, redirectUrl)),
				)
			}
		}

		return self
	}
}
