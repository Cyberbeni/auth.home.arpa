extension Config {
	struct User: Decodable {
		let users: [String: String]
	}
}
