import Elementary
import ElementaryHTMX

struct PasswordHasherView: HTML {
	var body: some HTML {
		form(
			.hx.post("/api/hash-password"),
			.hx.target("#password-hash"),
			.init(name: "hx-on:htmx:before-request", value: "document.getElementById('password-hash').innerHTML='-'"),
		) {
			table {
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
						input(.type(.submit), .value("Generate hash"), .id("submit-button"))
					}
				}
				tr {
					td {
						label {
							"Password hash:"
						}
					}
					td {
						label(.id("password-hash")) {
							"-"
						}
					}
				}
			}
		}
	}
}
