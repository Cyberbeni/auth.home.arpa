import HTTPTypes
import Hummingbird

private struct LoginRequest: Decodable {
	let user: String
	let password: String
}

extension Router {
	@discardableResult
	func addLoginRoutes(userService: UserService) -> Self {
		let currentUrlHeaderName = HTTPField.Name("Hx-Current-Url")
		let hxRedirectHeaderName = HTTPField.Name("HX-Redirect")

		post("api/login") { request, context in
			guard let currentUrlHeaderName,
			      let hxRedirectHeaderName,
			      let currentUrlString = request.headers[currentUrlHeaderName],
					let currentUrl = URL(string: currentUrlString),
			      let currentUrlComponents = URLComponents(string: currentUrlString),
			      let redirectUrl = currentUrlComponents.queryItems?.first(where: { $0.name == "redirect" })?.value,
			      let loginRequest = try? await URLEncodedFormDecoder().decode(LoginRequest.self, from: request, context: context)
			else {
				// TODO: also update UI
				return Response(
					status: .badRequest,
				)
			}
			guard var cookie = userService.checkPassword(user: loginRequest.user, password: loginRequest.password) else {
				// TODO: also update UI
				return Response(
					status: .unauthorized,
				)
			}
			if let host = currentUrl.host {
				Log.info("Host: \(host)")
				let ipRegex = /^(((?!25?[6-9])[12]\d|[1-9])?\d\.?\b){4}$/
				if host.firstMatch(of: ipRegex) == nil {
					// let hostComponents = host.components(separatedBy: ".")
					// cookie.append("; Domain=\(hostComponents.suffix(2).joined(separator: "."))")
				}
			}
			cookie.append("; HttpOnly")
			cookie.append("; Max-Age=2592000") // 30 days
			cookie.append("; Path=/") // 30 days
			if currentUrlString.hasPrefix("https://") {
				cookie.append("; Secure")
			}
			Log.info("Cookie: \(cookie)")
			return Response(
				status: .noContent,
				headers: [
					hxRedirectHeaderName: redirectUrl,
					.setCookie: cookie
				],
			)
		}

		return self
	}
}
