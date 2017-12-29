package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Foo", func() {
	BasePath("/foo")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(FooMedia)
	Description("Describes a foo.")

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all foos")
		Response(OK, CollectionOf(FooMedia))
	})
})

var FooPayload = Type("FooPayload", func() {
	Description("Foo Description.")

	Attribute("id", String, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id,omitempty")
	})
	Attribute("name", String, "Foo name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name,omitempty")
	})

	Required("name")
})

var FooMedia = MediaType("application/fooapi.fooentity", func() {
	Description("Foo response")
	TypeName("FooMedia")
	ContentType("application/json")
	Reference(FooPayload)

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
		Description("`tiny` is the view used to create new foos.")
		Attribute("name")
	})
})
