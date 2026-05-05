extension Config {
	struct General: Decodable {
		static var `default`: Self {
			.init(
				_title: nil,
				_sessionCookie: nil,
				_sessionDuration: nil,
				secret: nil,
			)
		}

		private let _title: String?
		var title: String { _title ?? "SSO" }
		private let _sessionCookie: Bool?
		var sessionCookie: Bool { _sessionCookie ?? false }
		private let _sessionDuration: TimeInterval?
		var sessionDuration: TimeInterval {
			max(
				(15 * 60) as TimeInterval,
				min(
					_sessionDuration ?? (sessionCookie
						? (23 * 3600) as TimeInterval
						: (30 * 24 * 3600) as TimeInterval),
					(180 * 24 * 3600) as TimeInterval,
				),
			)
		}

		let secret: String?

		enum CodingKeys: String, CodingKey {
			case _title = "title"
			case _sessionCookie = "sessionCookie"
			case _sessionDuration = "sessionDuration"
			case secret
		}
	}
}
