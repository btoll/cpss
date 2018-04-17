package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("FundingSource", func() {
	BasePath("/fundingsource")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(FundingSourceMedia)
	Description("Describes a FundingSource code.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new FundingSource code.")
		Payload(FundingSourcePayload)
		Response(OK, FundingSourceMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(FundingSourcePayload)
		Params(func() {
			Param("id", Integer, "FundingSource ID")
		})
		Description("Update a fundingsource code by id.")
		Response(OK, FundingSourceMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "FundingSource ID")
		})
		Description("Delete a fundingsource code by id.")
		Response(OK, func() {
			Status(200)
			Media(FundingSourceMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all fundingsource codes")
		Response(OK, CollectionOf(FundingSourceMedia))
	})

	Action("page", func() {
		Routing(GET("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of FundingSources and a pager object")
		})
		Description("Get a page of FundingSources")
		Response(OK, func() {
			Status(200)
			Media(FundingSourceMedia, "paging")
		})
	})
})

var FundingSourcePayload = Type("FundingSourcePayload", func() {
	Description("FundingSource Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("name", String, "FundingSource name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name")
	})

	Required("name")
})

var FundingSourceItem = Type("FundingSourceItem", func() {
	Reference(FundingSourcePayload)

	Attribute("id")
	Attribute("name")

	Required("id", "name")
})

var FundingSourceMedia = MediaType("application/fundingsource.fundingsource", func() {
	Description("FundingSource response")
	TypeName("FundingSourceMedia")
	ContentType("application/json")
	Reference(FundingSourcePayload)

	Attributes(func() {
		Attribute("id")
		Attribute("name")
		Attribute("fundingsources", ArrayOf("FundingSourceItem"))
		Attribute("pager", Pager)

		Required("id", "name", "fundingsources", "pager")
	})

	View("default", func() {
		Attribute("id")
		Attribute("name")
	})

	View("paging", func() {
		Attribute("fundingsources")
		Attribute("pager")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new dia code.")
		Attribute("id")
	})
})
