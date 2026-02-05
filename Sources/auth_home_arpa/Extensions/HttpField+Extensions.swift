import HTTPTypes

extension HTTPField.Name {
	// Proxy headers
   static var xForwardedFor: Self { HTTPField.Name("X-Forwarded-For")! }
   static var xForwardedProto: Self { HTTPField.Name("X-Forwarded-Proto")! }
   static var xForwardedHost: Self { HTTPField.Name("X-Forwarded-Host")! }
   static var xForwardedUri: Self { HTTPField.Name("X-Forwarded-Uri")! }
	// HTMX headers
   static var hxCurrentUrl: Self { HTTPField.Name("Hx-Current-Url")! }
   static var hxRedirect: Self { HTTPField.Name("HX-Redirect")! }
}
