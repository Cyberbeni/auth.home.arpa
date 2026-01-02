import Elementary
import ElementaryHTMX

struct LoginPage: HTMLDocument {
	let staticFilesTimestamp: String

	var title: String { "Login" }

	var lang: String { "en" }

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))

		link(.href("/\(staticFilesTimestamp)/style.css"), .rel(.stylesheet))
		script(.src("/\(staticFilesTimestamp)/htmx.min.js")) {}
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
						input(.type(.text), .autocomplete("username"), .id("user"), .name("user"), .required)
					}
				}
				tr {
					td {
						label {
							"Password:"
						}
					}
					td {
						input(.type(.password), .autocomplete("current-password"), .id("password"), .name("password"), .required)
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
