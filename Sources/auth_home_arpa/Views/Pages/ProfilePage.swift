import Elementary

struct ProfilePage: HTMLDocument {
	let staticFilesTimestamp: String
	let invalidCookie: Bool
	let authToken: AuthToken?
	let ip: String

	var title: String { "Profile" }

	var lang: String { "en" }

	var head: some HTML {
		DefaultHtmlHead(staticFilesTimestamp: staticFilesTimestamp)
	}

	var body: some HTML {
		if invalidCookie {
			div { "Invalid cookie" }
		} else if let authToken {
			div { "Cookie:" }
			div { "- user: \(authToken.sub.value)" }
			div { "- expiration: \(authToken.exp.value.ISO8601Format(.init(timeZone: .current)))" }
			div { "- ip: \(authToken.ip)" }
			div { "- is valid: \(authToken.validate(ip: ip))" }
		} else {
			div { "No cookie" }
		}
		div { "Client:" }
		div { "- ip: \(ip)" }
	}
}
