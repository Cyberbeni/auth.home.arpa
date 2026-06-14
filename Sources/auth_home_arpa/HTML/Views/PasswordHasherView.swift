import Elementary
import ElementaryHTMX

struct PasswordHasherView: HTML {
	var body: some HTML {
		form(
			.class("grid"),
			.hx.post("/api/hash-password"),
			.hx.target("#password-hash"),
			.init(name: "hx-on:htmx:before-request", value: "document.getElementById('password-hash').innerHTML='-'"),
		) {
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
			input(.type(.submit), .value("Generate hash"))
			label {
				"Password hash:"
			}
			label(.id("password-hash")) {
				"-"
			}
		}
	}
}
