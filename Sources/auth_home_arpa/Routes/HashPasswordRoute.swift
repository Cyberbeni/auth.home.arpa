import Hummingbird
import HummingbirdBcrypt

private struct HashPasswordRequest: Decodable {
	let password: String
}

extension Router {
	@discardableResult
	func addHashPasswordRoute() -> Self {
		post("api/hash-password") { request, context in
			guard
				let hashPasswordRequest = try? await URLEncodedFormDecoder().decode(HashPasswordRequest.self, from: request, context: context)
			else {
				// TODO: also update UI
				return Response(
					status: .badRequest,
				)
			}
			let passwordHash = Bcrypt.hash(hashPasswordRequest.password)
			return Response(
				status: .ok,
				body: .init(byteBuffer: ByteBuffer(string: passwordHash)),
			)
		}
		return self
	}
}
