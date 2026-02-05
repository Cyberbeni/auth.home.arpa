extension Config {
	struct General: Decodable {
		static var `default`: Self {
			.init(_sessionDuration: nil, secret: nil)
		}

		private let _sessionDuration: TimeInterval?
		var sessionDuration: TimeInterval {
			max(
				(23 * 3600) as TimeInterval,
				min(
					_sessionDuration ?? (30 * 24 * 3600) as TimeInterval,
					(180 * 24 * 3600) as TimeInterval,
				),
			)
		}

		let secret: String?

		enum CodingKeys: String, CodingKey {
			case _sessionDuration = "sessionDuration"
			case secret
		}
	}
}
