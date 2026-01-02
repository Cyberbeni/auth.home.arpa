extension Config {
	struct Users: Decodable {
		let users: [String: String]
	}
}
