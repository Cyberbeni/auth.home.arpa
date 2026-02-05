import JWTKit
import LruCache

struct AuthToken: JWTPayload {
	fileprivate static let keys = JWTKeyCollection()

	var sub: SubjectClaim
	var exp: ExpirationClaim
	var ip: String

	func verify(using _: some JWTAlgorithm) async throws {}

	static func setupKeys(secret: String?) async {
		// TODO: rotate keys automatically
		if let secret {
			await AuthToken.keys.add(hmac: HMACKey(from: secret), digestAlgorithm: .sha256)
		} else {
			do {
				try await AuthToken.keys.add(eddsa: EdDSA.PrivateKey())
			} catch {
				Log.critical("Failed to generate private key for signing the JWTs.")
			}
		}
	}

	func sign() async throws -> String {
		try await Self.keys.sign(self)
	}

	func validate(ip: String) -> Bool {
		do {
			try exp.verifyNotExpired()
			return self.ip == ip
		} catch {
			return false
		}
	}
}

typealias AuthTokenWrapper = Result<AuthToken, any Error>

extension AuthTokenWrapper: @retroactive CacheItem {
	public init(fromCacheKey cookie: String) async {
		do {
			self = try await .success(AuthToken.keys.verify(cookie, as: AuthToken.self))
		} catch {
			self = .failure(error)
		}
	}
}
