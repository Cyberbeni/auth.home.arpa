import HummingbirdBcrypt
import LruCache

struct UserService {
	enum CheckCookieResult {
		case ok
		case missingRole
		case invalidOrMissing
	}

	let generalConfig: Config.General
	let userConfig: Config.User
	private let cache = LruCache<AuthTokenWrapper>(limit: 32)

	func checkPassword(user: String, password: String, ip: String) async -> String? {
		guard let hashedPassword = userConfig.users[user]?.password else {
			// Calculate hash, so clients can't get information about which user exists based on how long it takes to receive the response
			_ = Bcrypt.hash(password)
			return nil
		}
		guard Bcrypt.verify(password, hash: hashedPassword) else {
			return nil
		}
		let token = AuthToken(
			sub: .init(value: user),
			exp: .init(value: Date(timeIntervalSinceNow: generalConfig.sessionDuration)),
			ip: ip,
		)
		do {
			let jwt = try await token.sign()
			cache.insert(.success(token), forKey: jwt)
			return "\(Constants.cookieName)=\(jwt)"
		} catch {
			Log.error("Failed to sign JWT")
			return nil
		}
	}

	func checkCookie(_ cookie: String, ip: String, role: String?) async -> CheckCookieResult {
		switch await cache.get(cookie) {
		case let .success(token):
			guard token.validate(ip: ip) else {
				return .invalidOrMissing
			}
			if let role {
				if let user = userConfig.users[token.sub.value],
				   user.roles.contains(role)
				{
					return .ok
				} else {
					return .missingRole
				}
			} else {
				return .ok
			}
		case .failure:
			return .invalidOrMissing
		}
	}

	func authToken(_ cookie: String) async -> AuthToken? {
		switch await cache.get(cookie) {
		case let .success(token):
			return token
		case .failure:
			return nil
		}
	}
}
