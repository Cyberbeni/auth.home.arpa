import Elementary
import ElementaryHTMX

struct ForbiddenPage: HTMLDocument {
	let generalConfig: Config.General
	let staticFilesTimestamp: String
	let baseUrl: String
	let requiredRole: String?

	var title: String { "\(generalConfig.title) - Forbidden" }

	var lang: String { "en" }

	var head: some HTML {
		base(.href(baseUrl))
		DefaultHtmlHead(staticFilesTimestamp: staticFilesTimestamp)
	}

	var body: some HTML {
		div { "403 Forbidden" }
		div { "Required role: \(requiredRole, default: "-")" }
		// TODO: sign in with different user button
	}
}
