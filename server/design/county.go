package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("County", func() {
	BasePath("/county")
	Description("PA counties")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new county.")
		Payload(CountyPayload)
		Response(OK, func() {
			Status(200)
			Media(CountyMedia, "tiny")
		})
	})

	Action("show", func() {
		Routing(GET("/:id"))
		Params(func() {
			Param("id", Integer, "County ID")
		})
		Description("Get counties by county id.")
		Response(OK, func() {
			Status(200)
			Media(CollectionOf(CountyMedia))
		})
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(CountyPayload)
		Params(func() {
			Param("id", Integer, "County ID")
		})
		Description("Update a county by id.")
		Response(OK, CountyMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "County ID")
		})
		Description("Delete a county by id.")
		Response(OK, func() {
			Status(200)
			Media(CountyMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all the PA counties")
		Response(OK, CollectionOf(CountyMedia))
	})

	Action("page", func() {
		Routing(GET("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of counties and a pager object")
		})
		Description("Get a page of counties")
		Response(OK, func() {
			Status(200)
			Media(CountyMedia, "paging")
		})
	})
})

var CountyPayload = Type("CountyPayload", func() {
	Description("County Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("name", String, "Name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name")
	})

	Required("name")
})

var CountyItem = Type("countyItem", func() {
	Reference(CountyPayload)

	Attribute("id")
	Attribute("name")

	Required("id", "name")
})

var CountyMedia = MediaType("application/countyapi.countyentity", func() {
	Description("County response")
	TypeName("CountyMedia")
	ContentType("application/json")
	Reference(CountyPayload)

	Attributes(func() {
		// Better way, i.e., defining this twice?
		Attribute("id")
		Attribute("name")
		Attribute("counties", ArrayOf("countyItem"))
		Attribute("pager", Pager)

		Required("id", "name", "counties", "pager")
	})

	View("default", func() {
		Attribute("id", Integer)
		Attribute("name", String)
	})

	View("paging", func() {
		Attribute("counties")
		Attribute("pager")
	})

	View("tiny", func() {
		Attribute("id")
	})
})
