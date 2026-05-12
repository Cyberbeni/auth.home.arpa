import Hummingbird
import HummingbirdElementary

private struct AuthRequest: Decodable {
	let redirect: String
	let role: String?
}

extension Router {
	@discardableResult
	func addForwardAuthRoute(
		generalConfig: Config.General,
		staticFilesTimestamp: String,
		userService: UserService,
	) -> Self {
		get("api/auth") { request, context throws(Never) in
			guard let ip = request.headers[.xForwardedFor],
			      let authRequest = try? URLEncodedFormDecoder().decode(AuthRequest.self, from: request.uri.query ?? ""),
			      let redirectUrlBase = URL(string: authRequest.redirect),
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
			let checkCookieResult: UserService.CheckCookieResult
			if let cookie = request.cookies[Constants.cookieName] {
				checkCookieResult = await userService.checkCookie(cookie.value, ip: ip, role: authRequest.role)
			} else {
				checkCookieResult = .invalidOrMissing
			}
			switch checkCookieResult {
			case .ok:
				return Response(
					status: .noContent,
				)
			case .notInGroup:
				return HTMLResponse(
					status: .forbidden,
				) {
					ForbiddenPage(
						generalConfig: generalConfig,
						staticFilesTimestamp: staticFilesTimestamp,
						baseUrl: authRequest.redirect,
						loginUrl: redirectUrl,
						requiredRole: authRequest.role,
					)
				}.response(from: request, context: context)
			case .invalidOrMissing:
				return Response(
					status: .found,
					headers: HTTPFields(dictionaryLiteral: (.location, redirectUrl)),
				)
			}
		}

		return self
	}
}
