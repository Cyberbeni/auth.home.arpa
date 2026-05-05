import Elementary

struct DefaultHtmlHead: HTML {
	let staticFilesTimestamp: String

	var body: some HTML {
		meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))
		// TODO: theme-color
		link(.href("/\(staticFilesTimestamp)/favicon.svg"), .rel(.icon))
		link(.href("/\(staticFilesTimestamp)/style.css"), .rel(.stylesheet))
		script(.src("/\(staticFilesTimestamp)/htmx.min.js")) {}
	}
}
