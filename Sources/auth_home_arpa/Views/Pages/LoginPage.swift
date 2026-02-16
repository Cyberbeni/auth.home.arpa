import Elementary
import ElementaryHTMX

struct LoginPage: HTMLDocument {
	let staticFilesTimestamp: String

	var title: String { "Login" }

	var lang: String { "en" }

	var head: some HTML {
		DefaultHtmlHead(staticFilesTimestamp: staticFilesTimestamp)
	}

	var body: some HTML {
		form(.hx.post("/api/login")) {
			table {
				tr {
					td {
						label {
							"User:"
						}
					}
					td {
						input(
							.type(.text),
							.autocomplete("username"),
							.id("user"),
							.name("user"),
							.init(name: "autocapitalize", value: "off"),
							.required,
						)
					}
				}
				tr {
					td {
						label {
							"Password:"
						}
					}
					td {
						input(
							.type(.password),
							.autocomplete("current-password"),
							.id("password"),
							.name("password"),
							.required,
						)
					}
				}
				tr {
					td(.init(name: "colspan", value: "2")) {
						input(.type(.submit), .value("Login"), .id("submit-button"))
					}
				}
			}
		}
	}
}
