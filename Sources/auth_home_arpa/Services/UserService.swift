import LruCache

@globalActor
actor PasswordHasher {
	static let shared = PasswordHasher()
}

struct UserService {
	private let userConfig: Config.User
	private let cache = LruCache<AuthTokenWrapper>(limit: 32)

	init(userConfig: Config.User) {
		self.userConfig = userConfig
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
			let jwt = try await token.sign()
			cache.insert(.success(token), forKey: jwt)
			return "\(Constants.cookieName)=\(jwt)"
		} catch {
			return nil
		}
	}

	func checkCookie(_ cookie: String, ip: String) async -> Bool {
		switch await cache.get(cookie) {
		case let .success(token):
			return token.validate(ip: ip)
		case .failure:
			return false
		}
	}
}
