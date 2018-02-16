package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Status", func() {
	BasePath("/status")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(StatusMedia)
	Description("Describes a status.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new sport.")
		Payload(StatusPayload)
		Response(OK, StatusMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(StatusPayload)
		Params(func() {
			Param("id", Integer, "Status ID")
		})
		Description("Update a status by id.")
		Response(OK, StatusMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "Status ID")
		})
		Description("Delete a status by id.")
		Response(OK, func() {
			Status(200)
			Media(StatusMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all status")
		Response(OK, CollectionOf(StatusMedia))
	})
})

var StatusPayload = Type("StatusPayload", func() {
	Description("Status Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("name", String, "Status name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name")
	})

	Required("name")
})

var StatusMedia = MediaType("application/statusapi.statusentity", func() {
	Description("Status response")
	TypeName("StatusMedia")
	ContentType("application/json")
	Reference(StatusPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("name")

		Required("id", "name")
	})

	View("default", func() {
		Attribute("id")
		Attribute("name")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new status.")
		Attribute("id")
	})
})
