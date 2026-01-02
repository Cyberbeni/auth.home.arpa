#if canImport(Musl)
import Musl
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

actor UserService {
	nonisolated let userConfig: Config.User

	init(userConfig: Config.User) {
		self.userConfig = userConfig
	}

	nonisolated func checkPassword(user: String, password: String) -> String? {
		guard let hashedPassword = userConfig.users[user],
			let result = crypt(password, hashedPassword).map({ String(cString: $0) }),
			result == hashedPassword
		else {
			return nil
		}
		return "\(Constants.cookieName)=\(Data(user.utf8).base64EncodedString()):\(hashedPassword)"
	}

	nonisolated func checkCookie(_ cookie: String) -> Bool {
		let cookieComponents = cookie.components(separatedBy: ":")
		guard cookieComponents.count == 2,
			let encodedUser = cookieComponents.first,
			let hashedPassword = cookieComponents.last,
			let userData = Data(base64Encoded: encodedUser),
			let user = String(data: userData, encoding: .utf8)
		else {
			return false
		}
		return userConfig.users[user] == hashedPassword
	}
}
