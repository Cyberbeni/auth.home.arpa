import Elementary

struct LoginPage: HTMLDocument {
	var title: String { "Login" }

	var lang: String { "en" }

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name("viewport"), .content("width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"))
	}

	// TODO: login page
	var body: some HTML {
		div {
			"Text"
		}
	}
}
