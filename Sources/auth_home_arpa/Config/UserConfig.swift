extension Config {
	struct User: Decodable {
		let users: [String: UserDetails]
	}

	struct UserDetails: Decodable {
		let password: String
		let roles: [String]

		enum CodingKeys: String, CodingKey {
			case password
			case roles
		}

		init(from decoder: any Decoder) throws {
			do {
				let container = try decoder.singleValueContainer()
				password = try container.decode(String.self)
				roles = []
			} catch {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				password = try container.decode(String.self, forKey: .password)
				roles = try container.decodeIfPresent([String].self, forKey: .roles) ?? []
			}
		}
	}
}
