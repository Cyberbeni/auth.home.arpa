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
			guard
				let currentUrlHeaderName,
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
			guard var cookie = await userService.checkPassword(user: loginRequest.user, password: loginRequest.password) else {
				// TODO: also update UI
				return Response(
					status: .unauthorized,
				)
			}
			if let host = currentUrl.host {
				let ipRegex = /^(?:(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])(\.(?!$)|$)){4}$/
				if host.firstMatch(of: ipRegex) == nil,
				   case let hostComponents = host.components(separatedBy: "."),
				   hostComponents.count > 2
				{
					cookie.append("; Domain=\(hostComponents.dropFirst().joined(separator: "."))")
				}
			}
			cookie.append("; HttpOnly")
			cookie.append("; Max-Age=2592000") // 30 days
			cookie.append("; Path=/")
			if currentUrlString.hasPrefix("https://") {
				cookie.append("; Secure")
			}
			return Response(
				status: .noContent,
				headers: [
					hxRedirectHeaderName: redirectUrl,
					.setCookie: cookie,
				],
			)
		}

		return self
	}
}
