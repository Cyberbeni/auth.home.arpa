import HTTPTypes
import Hummingbird

private struct LoginRequest: Decodable {
	let user: String
	let password: String
}

extension Router {
	@discardableResult
	func addLoginRoutes() -> Self {
		let currentUrlHeaderName = HTTPField.Name("Hx-Current-Url")
		let hxRedirectHeaderName = HTTPField.Name("HX-Redirect")
		post("api/login") { request, context in
			guard let currentUrlHeaderName,
			      let hxRedirectHeaderName,
			      let currentUrlString = request.headers[currentUrlHeaderName],
			      let currentUrlComponents = URLComponents(string: currentUrlString),
			      let redirectUrl = currentUrlComponents.queryItems?.first(where: { $0.name == "redirect" })?.value
			else {
				// TODO: also update UI
				return Response(
					status: .badRequest,
				)
			}
			// TODO: check user/password
			let loginRequest = try await URLEncodedFormDecoder().decode(LoginRequest.self, from: request, context: context)
			guard !loginRequest.user.isEmpty,
			      !loginRequest.password.isEmpty
			else {
				// TODO: also update UI
				return Response(
					status: .unauthorized,
				)
			}
			// TODO: set cookie
			return Response(
				status: .noContent,
				headers: [
					hxRedirectHeaderName: redirectUrl,
				],
			)
		}

		return self
	}
}
