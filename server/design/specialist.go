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
		Response(OK, SpecialistMedia)
	})

	Action("show", func() {
		Routing(GET("/:id"))
		Params(func() {
			Param("id", Integer, "Specialist ID")
		})
		Description("Get a specialist by id.")
		Response(OK, SpecialistMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(SpecialistPayload)
		Params(func() {
			Param("id", Integer, "Specialist ID")
		})
		Description("Update a specialist by id.")
		Response(OK, SpecialistMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "Specialist ID")
		})
		Description("Delete a specialist by id.")
		Response(OK, func() {
			Status(200)
			Media(SpecialistMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all specialists")
		Response(OK, ArrayOf("specialistItem"))
	})

	Action("page", func() {
		Routing(POST("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of specialists and a pager object")
		})
		Description("Get a page of specialists that may be filtered")
		Payload(SpecialistQueryPayload)
		Response(OK, func() {
			Status(200)
			Media(SpecialistMedia, "paging")
		})
	})
})

var SpecialistPayload = Type("SpecialistPayload", func() {
	Description("Specialist Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("username", String, "Specialist username", func() {
		Metadata("struct:tag:datastore", "username,noindex")
		Metadata("struct:tag:json", "username")
	})
	Attribute("password", String, "Specialist password", func() {
		Metadata("struct:tag:datastore", "password,noindex")
		Metadata("struct:tag:json", "password")
	})
	Attribute("firstname", String, "Specialist firstname", func() {
		Metadata("struct:tag:datastore", "firstname,noindex")
		Metadata("struct:tag:json", "firstname")
	})
	Attribute("lastname", String, "Specialist lastname", func() {
		Metadata("struct:tag:datastore", "lastname,noindex")
		Metadata("struct:tag:json", "lastname")
	})
	Attribute("email", String, "Specialist email", func() {
		Metadata("struct:tag:datastore", "email,noindex")
		Metadata("struct:tag:json", "email")
	})
	Attribute("payrate", Number, "Specialist payrate", func() {
		Metadata("struct:tag:datastore", "payrate,noindex")
		Metadata("struct:tag:json", "payrate")
	})
	Attribute("authLevel", Integer, "Specialist authorization level", func() {
		Metadata("struct:tag:datastore", "authLevel,noindex")
		Metadata("struct:tag:json", "authLevel")
	})

	Required("username", "password", "firstname", "lastname", "email", "payrate", "authLevel")
})

var SpecialistQueryPayload = Type("SpecialistQueryPayload", func() {
	Description("Specialist Query Description.")

	Attribute("whereClause", String, "where clause", func() {
		Metadata("struct:tag:datastore", "whereClause,noindex")
		Metadata("struct:tag:json", "whereClause")
	})
})

var SpecialistItem = Type("specialistItem", func() {
	Reference(SpecialistPayload)

	Attribute("id")
	Attribute("username")
	Attribute("password")
	Attribute("firstname")
	Attribute("lastname")
	Attribute("email")
	Attribute("payrate")
	Attribute("authLevel")

	Required("id", "username", "password", "firstname", "lastname", "email", "payrate", "authLevel")

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
		Attribute("authLevel")
		Attribute("users", ArrayOf("specialistItem"))
		Attribute("pager", Pager)

		Required("id", "username", "password", "firstname", "lastname", "email", "payrate", "authLevel", "users", "pager")
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

	View("paging", func() {
		Attribute("users")
		Attribute("pager")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new specialists.")
		Attribute("id")
	})
})
