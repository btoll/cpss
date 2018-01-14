package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Specialist", func() {
	BasePath("/specialist")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(SpecialistMedia)
	Description("Describes a specialist.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new sport.")
		Payload(SpecialistPayload)
		Response(OK, func() {
			Status(200)
			Media(SpecialistMedia, "tiny")
		})
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", String, "Specialist ID")
		})
		Description("Delete a specialist by id.")
		Response(OK, func() {
			Status(200)
		})
		Response(NoContent)
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all specialists")
		Response(OK, CollectionOf(SpecialistMedia))
	})
})

var SpecialistPayload = Type("SpecialistPayload", func() {
	Description("Specialist Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id,omitempty")
	})
	Attribute("username", String, "Specialist username", func() {
		Metadata("struct:tag:datastore", "username,noindex")
		Metadata("struct:tag:json", "username,omitempty")
	})
	Attribute("password", String, "Specialist password", func() {
		Metadata("struct:tag:datastore", "password,noindex")
		Metadata("struct:tag:json", "password,omitempty")
	})
	Attribute("firstname", String, "Specialist firstname", func() {
		Metadata("struct:tag:datastore", "firstname,noindex")
		Metadata("struct:tag:json", "firstname,omitempty")
	})
	Attribute("lastname", String, "Specialist lastname", func() {
		Metadata("struct:tag:datastore", "lastname,noindex")
		Metadata("struct:tag:json", "lastname,omitempty")
	})
	Attribute("email", String, "Specialist email", func() {
		Metadata("struct:tag:datastore", "email,noindex")
		Metadata("struct:tag:json", "email,omitempty")
	})
	Attribute("payrate", Number, "Specialist payrate", func() {
		Metadata("struct:tag:datastore", "payrate,noindex")
		Metadata("struct:tag:json", "payrate,omitempty")
	})

	Required("username", "password", "firstname", "lastname", "email", "payrate")
})

var SpecialistMedia = MediaType("application/specialistapi.specialistentity", func() {
	Description("Specialist response")
	TypeName("SpecialistMedia")
	ContentType("application/json")
	Reference(SpecialistPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("username")
		Attribute("password")
		Attribute("firstname")
		Attribute("lastname")
		Attribute("email")
		Attribute("payrate")

		Required("id", "username", "password", "firstname", "lastname", "email", "payrate")
	})

	View("default", func() {
		Attribute("id")
		Attribute("username")
		Attribute("password")
		Attribute("firstname")
		Attribute("lastname")
		Attribute("email")
		Attribute("payrate")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new specialists.")
		Attribute("id")
	})
})
