import HummingbirdBcrypt
import LruCache

struct UserService {
	let generalConfig: Config.General
	let userConfig: Config.User
	private let cache = LruCache<AuthTokenWrapper>(limit: 32)

	func checkPassword(user: String, password: String, ip: String) async -> String? {
		guard
			let hashedPassword = userConfig.users[user],
			Bcrypt.verify(password, hash: hashedPassword)
		else {
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

	func authToken(_ cookie: String) async -> AuthToken? {
		switch await cache.get(cookie) {
		case let .success(token):
			return token
		case .failure:
			return nil
		}
	}
}
