import HTTPTypes
import Hummingbird

extension Router {
	@discardableResult
	func addForwardAuthRoutes(userService: UserService) -> Self {
		let ipHeaderName = HTTPField.Name("X-Forwarded-For")
		let protoHeaderName = HTTPField.Name("X-Forwarded-Proto")
		let hostHeaderName = HTTPField.Name("X-Forwarded-Host")
		let uriHeaderName = HTTPField.Name("X-Forwarded-Uri")

		get("api/auth") { request, _ in
			guard let ipHeaderName,
			      let ip = request.headers[ipHeaderName]
			else {
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
					let protoHeaderName,
					let hostHeaderName,
					let uriHeaderName,
					let forwardedProto = request.headers[protoHeaderName],
					let forwardedHost = request.headers[hostHeaderName],
					let forwardedUri = request.headers[uriHeaderName]
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
