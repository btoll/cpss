package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("ServiceCode", func() {
	BasePath("/servicecode")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(ServiceCodeMedia)
	Description("Describes a service code.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new service code.")
		Payload(ServiceCodePayload)
		Response(OK, ServiceCodeMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(ServiceCodePayload)
		Params(func() {
			Param("id", Integer, "Service Code ID")
		})
		Description("Update a service code by id.")
		Response(OK, ServiceCodeMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "Service Code ID")
		})
		Description("Delete a service code by id.")
		Response(OK, func() {
			Status(200)
			Media(ServiceCodeMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all service codes")
		Response(OK, CollectionOf(ServiceCodeMedia))
	})
})

var ServiceCodePayload = Type("ServiceCodePayload", func() {
	Description("Service Code Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("name", String, "Service code name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name")
	})

	Required("name")
})

var ServiceCodeMedia = MediaType("application/servicecodeapi.servicecodeentity", func() {
	Description("Service code response")
	TypeName("ServiceCodeMedia")
	ContentType("application/json")
	Reference(ServiceCodePayload)

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
		Description("`tiny` is the view used to create new service code.")
		Attribute("id")
	})
})
