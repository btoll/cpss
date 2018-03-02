package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("City", func() {
	BasePath("/city")
	Description("PA counties")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new city.")
		Payload(CityPayload)
		Response(OK, func() {
			Status(200)
			Media(CityMedia, "tiny")
		})
	})

	Action("show", func() {
		Routing(GET("/:id"))
		Params(func() {
			Param("id", Integer, "City ID")
		})
		Description("Get cities by county id.")
		Response(OK, func() {
			Status(200)
			Media(CollectionOf(CityMedia))
		})
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(CityPayload)
		Params(func() {
			Param("id", Integer, "City ID")
		})
		Description("Update a city by id.")
		Response(OK, CityMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "City ID")
		})
		Description("Delete a city by id.")
		Response(OK, func() {
			Status(200)
			Media(CityMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all cities")
		Response(OK, CollectionOf(CityMedia))
	})

	Action("page", func() {
		Routing(GET("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of cities and a pager object")
		})
		Description("Get a page of cities")
		Response(OK, func() {
			Status(200)
			Media(CityMedia, "paging")
		})
	})
})

var CityPayload = Type("CityPayload", func() {
	Description("City Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("name", String, "Name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name")
	})
	Attribute("zip", String, "zip", func() {
		Metadata("struct:tag:datastore", "zip,noindex")
		Metadata("struct:tag:json", "zip")
	})
	Attribute("county", Integer, "county", func() {
		Metadata("struct:tag:datastore", "county")
		Metadata("struct:tag:json", "county")
	})
	Attribute("state", String, "state", func() {
		Metadata("struct:tag:datastore", "state,noindex")
		Metadata("struct:tag:json", "state")
	})

	Required("name", "zip", "county", "state")
})

var CityItem = Type("cityItem", func() {
	Reference(CityPayload)

	Attribute("id")
	Attribute("name")
	Attribute("zip")
	Attribute("county")
	Attribute("state")

	Required("id", "name", "zip", "county", "state")
})

var CityMedia = MediaType("application/cityapi.cityentity", func() {
	Description("City response")
	TypeName("CityMedia")
	ContentType("application/json")
	Reference(CityPayload)

	Attributes(func() {
		// Better way, i.e., defining this twice?
		Attribute("id")
		Attribute("name")
		Attribute("zip")
		Attribute("county")
		Attribute("state")
		Attribute("cities", ArrayOf("cityItem"))
		Attribute("pager", Pager)

		Required("id", "name", "zip", "county", "state", "cities", "pager")
	})

	View("default", func() {
		Attribute("id", Integer)
		Attribute("name", String)
		Attribute("zip", String)
		Attribute("county", Integer)
		Attribute("state", String)
	})

	View("paging", func() {
		Attribute("cities")
		Attribute("pager")
	})

	View("tiny", func() {
		Attribute("id")
	})
})
