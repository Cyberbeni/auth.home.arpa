import HTTPTypes
import Hummingbird

private struct LoginRequest: Decodable {
	let user: String
	let password: String
}

extension Router {
	@discardableResult
	func addLoginRoutes(generalConfig: Config.General, userService: UserService) -> Self {
		post("api/login") { request, context in
			guard
				let ip = request.headers[.xForwardedFor],
				let currentUrlString = request.headers[.hxCurrentUrl],
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
			guard var cookie = try await userService.checkPassword(user: loginRequest.user, password: loginRequest.password, ip: ip) else {
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
			cookie.append("; Max-Age=\(Int(generalConfig.sessionDuration))")
			cookie.append("; Path=/")
			if currentUrlString.hasPrefix("https://") {
				cookie.append("; Secure")
			}
			return Response(
				status: .noContent,
				headers: [
					.hxRedirect: redirectUrl,
					.setCookie: cookie,
				],
			)
		}

		return self
	}
}
