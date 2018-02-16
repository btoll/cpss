package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("County", func() {
	BasePath("/county")
	Description("PA counties")

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get a list of all the PA counties")
		Response(OK, CollectionOf(CountyMedia))
	})
})

var CountyPayload = Type("CountyPayload", func() {
	Description("County Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
})

var CountyMedia = MediaType("application/countyapi.countyentity", func() {
	Description("County response")
	TypeName("CountyMedia")
	ContentType("application/json")
	Reference(CountyPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("name", String)

		Required("id", "name")
	})

	View("default", func() {
		Attribute("id")
		Attribute("name")
	})
})
