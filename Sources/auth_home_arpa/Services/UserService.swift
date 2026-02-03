import JWTKit

@globalActor
actor PasswordHasher {
	static let shared = PasswordHasher()
}

struct AuthToken: JWTPayload {
	// TODO: add keys
	static let keys = JWTKeyCollection()

	var sub: SubjectClaim
	var exp: ExpirationClaim
	// TODO: StringClaim?
	var ip: String

	func verify(using _: some JWTAlgorithm) async throws {
		try exp.verifyNotExpired()
	}
}

struct UserService {
	private let userConfig: Config.User

	init(userConfig: Config.User) {
		self.userConfig = userConfig
		// TODO: read existing or create new EdDSA key during App startup
		// TODO: add config deciding if we want to persist the key
		// TODO: key expiration?
		Task { await AuthToken.keys.add(hmac: "secret2", digestAlgorithm: .sha256) }
	}

	func checkPassword(user: String, password: String, ip: String) async throws -> String? {
		guard
			let hashedPassword = userConfig.users[user],
			// crypt(...) uses static storage, so usage needs to be isolated
			let result = await Task(operation: { @PasswordHasher in
				return crypt(password, hashedPassword).map { String(cString: $0) }
			}).value,
			result == hashedPassword
		else {
			return nil
		}
		// TODO: add config to set expiration
		let token = AuthToken(sub: .init(value: user), exp: .init(value: .init(timeIntervalSinceNow: 2_592_000)), ip: ip)
		do {
			let jwt = try await AuthToken.keys.sign(token)
			// TODO: add JWT to cache
			return "\(Constants.cookieName)=\(jwt)"
		} catch {
			return nil
		}
	}

	func checkCookie(_ cookie: String, ip: String) async -> Bool {
		// TODO: use cache
		do {
			let payload = try await AuthToken.keys.verify(cookie, as: AuthToken.self)
			return payload.ip == ip
		} catch {
			return false
		}
	}
}
