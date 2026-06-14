import Elementary
import ElementaryHTMX

struct LoginPage: HTMLDocument {
	let generalConfig: Config.General
	let staticFilesTimestamp: String

	var title: String { "\(generalConfig.title) - Login" }

	var lang: String { "en" }

	var head: some HTML {
		DefaultHtmlHead(staticFilesTimestamp: staticFilesTimestamp)
	}

	var body: some HTML {
		form(.hx.post("/api/login")) {
			// Proton Pass doesn't autofill if the labels and inputs are at the root of the form
			div(.class("login-form grid")) {
				label {
					"User:"
				}
				input(
					.type(.text),
					.autocomplete("username"),
					.id("user"),
					.name("user"),
					.init(name: "autocapitalize", value: "off"),
					.required,
				)
				label {
					"Password:"
				}
				input(
					.type(.password),
					.autocomplete("current-password"),
					.id("password"),
					.name("password"),
					.required,
				)
				input(.type(.submit), .value("Login"), .id("login-button"))
			}
		}
	}
}
