import Elementary

struct IndexPage: HTMLDocument {
	let generalConfig: Config.General
	let staticFilesTimestamp: String
	let invalidCookie: Bool
	let authToken: AuthToken?
	let ip: String

	var title: String { generalConfig.title }

	var lang: String { "en" }

	var head: some HTML {
		DefaultHtmlHead(staticFilesTimestamp: staticFilesTimestamp)
	}

	var body: some HTML {
		ProfileView(
			invalidCookie: invalidCookie,
			authToken: authToken,
			ip: ip,
		)
		br()
		PasswordHasherView()
	}
}
