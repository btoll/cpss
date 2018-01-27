package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Session", func() {
	BasePath("/session")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(SessionMedia)
	Description("Describes a session.")

	Action("auth", func() {
		Routing(POST("/auth"))
		Description("Authenticate the user.")
		Payload(SessionPayload)
		Response(OK, SessionMedia)
	})

	Action("hash", func() {
		Routing(POST("/hash"))
		Description("Hash the new password.")
		Payload(SessionPayload)
		Response(OK, func() {
			Status(200)
			Media(SessionMedia, "tiny")
		})
	})
})

var SessionPayload = Type("SessionPayload", func() {
	Description("Session Description.")

	Attribute("id", Integer, "Session id", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id,omitempty")
	})
	Attribute("username", String, "Session username", func() {
		Metadata("struct:tag:datastore", "username,noindex")
		Metadata("struct:tag:json", "username,omitempty")
	})
	Attribute("password", String, "Session password", func() {
		Metadata("struct:tag:datastore", "password,noindex")
		Metadata("struct:tag:json", "password,omitempty")
	})
	Attribute("firstname", String, "Session firstname", func() {
		Metadata("struct:tag:datastore", "firstname,noindex")
		Metadata("struct:tag:json", "firstname,omitempty")
	})
	Attribute("lastname", String, "Session lastname", func() {
		Metadata("struct:tag:datastore", "lastname,noindex")
		Metadata("struct:tag:json", "lastname,omitempty")
	})
	Attribute("email", String, "Session email", func() {
		Metadata("struct:tag:datastore", "email,noindex")
		Metadata("struct:tag:json", "email,omitempty")
	})
	Attribute("payrate", Number, "Session payrate", func() {
		Metadata("struct:tag:datastore", "payrate,noindex")
		Metadata("struct:tag:json", "payrate,omitempty")
	})
	Attribute("authLevel", Integer, "Session authLevel", func() {
		Metadata("struct:tag:datastore", "authLevel,noindex")
		Metadata("struct:tag:json", "authLevel,omitempty")
	})

	Required("password")
})

var SessionMedia = MediaType("application/sessionapi.sessionentity", func() {
	Description("Session response")
	TypeName("SessionMedia")
	ContentType("application/json")
	Reference(SessionPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("username")
		Attribute("password")
		Attribute("firstname")
		Attribute("lastname")
		Attribute("email")
		Attribute("payrate", Number)
		Attribute("authLevel", Integer)

		Required("id", "username", "password", "firstname", "lastname", "email", "payrate", "authLevel")
	})

	View("default", func() {
		Attribute("id")
		Attribute("username")
		Attribute("password")
		Attribute("firstname")
		Attribute("lastname")
		Attribute("email")
		Attribute("payrate")
		Attribute("authLevel")
	})

	View("tiny", func() {
		Attribute("id")
		Attribute("password")
	})
})
