#if canImport(FoundationEssentials)
	import FoundationEssentials

	public final class DateFormatter: @unchecked Sendable {
		private init() {}
		public func date(from _: String) -> Date? {
			fatalError("Unreachable")
		}

		public func string(from _: Date) -> String {
			fatalError("Unreachable")
		}
	}
#endif
