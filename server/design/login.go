package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Login", func() {
	BasePath("/login")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(LoginMedia)
	Description("Describes a login.")

	Action("verify", func() {
		Routing(POST("/"))
		Description("Verify the login.")
		Payload(LoginPayload)
		Response(OK, LoginMedia)
	})
})

var LoginPayload = Type("LoginPayload", func() {
	Description("Login Description.")

	Attribute("username", String, "Login username", func() {
		Metadata("struct:tag:datastore", "username,noindex")
		Metadata("struct:tag:json", "username,omitempty")
	})
	Attribute("password", String, "Login password", func() {
		Metadata("struct:tag:datastore", "password,noindex")
		Metadata("struct:tag:json", "password,omitempty")
	})

	Required("username", "password")
})

var LoginMedia = MediaType("application/loginapi.loginentity", func() {
	Description("Login response")
	TypeName("LoginMedia")
	ContentType("application/json")
	Reference(LoginPayload)

	Attributes(func() {
		Attribute("username")
		Attribute("password")
		Attribute("email", String)
		Attribute("authLevel", Integer)

		Required("username", "password", "email", "authLevel")
	})

	View("default", func() {
		Attribute("username")
		Attribute("password")
		Attribute("email")
		Attribute("authLevel")
	})
})
