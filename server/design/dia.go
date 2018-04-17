package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("DIA", func() {
	BasePath("/dia")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(DIAMedia)
	Description("Describes a DIA code.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new DIA code.")
		Payload(DIAPayload)
		Response(OK, DIAMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(DIAPayload)
		Params(func() {
			Param("id", Integer, "DIA ID")
		})
		Description("Update a dia code by id.")
		Response(OK, DIAMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "DIA ID")
		})
		Description("Delete a dia code by id.")
		Response(OK, func() {
			Status(200)
			Media(DIAMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all dia codes")
		Response(OK, CollectionOf(DIAMedia))
	})

	Action("page", func() {
		Routing(GET("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of DIAs and a pager object")
		})
		Description("Get a page of DIAs")
		Response(OK, func() {
			Status(200)
			Media(DIAMedia, "paging")
		})
	})
})

var DIAPayload = Type("DIAPayload", func() {
	Description("DIA Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("name", String, "DIA name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name")
	})

	Required("name")
})

var DIAItem = Type("DIAItem", func() {
	Reference(DIAPayload)

	Attribute("id")
	Attribute("name")

	Required("id", "name")
})

var DIAMedia = MediaType("application/diacodeapi.diacodeentity", func() {
	Description("DIA response")
	TypeName("DIAMedia")
	ContentType("application/json")
	Reference(DIAPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("name")
		Attribute("dias", ArrayOf("DIAItem"))
		Attribute("pager", Pager)

		Required("id", "name", "dias", "pager")
	})

	View("default", func() {
		Attribute("id")
		Attribute("name")
	})

	View("paging", func() {
		Attribute("dias")
		Attribute("pager")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new dia code.")
		Attribute("id")
	})
})
