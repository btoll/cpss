package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Consumer", func() {
	BasePath("/consumer")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(ConsumerMedia)
	Description("Describes a consumer.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new consumer.")
		Payload(ConsumerPayload)
		Response(OK, func() {
			Status(200)
			Media(ConsumerMedia, "tiny")
		})
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(ConsumerPayload)
		Params(func() {
			Param("id", Integer, "Consumer ID")
		})
		Description("Update a consumer by id.")
		Response(OK, ConsumerMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "Consumer ID")
		})
		Description("Delete a consumer by id.")
		Response(OK, func() {
			Status(200)
			Media(ConsumerMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all consumers")
		Response(OK, ArrayOf("consumerItem"))
	})

	Action("page", func() {
		Routing(POST("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of consumers and a pager object")
		})
		Description("Get a page of consumers that may be filtered")
		Payload(ConsumerQueryPayload)
		Response(OK, func() {
			Status(200)
			Media(ConsumerMedia, "paging")
		})
	})
})

var ConsumerPayload = Type("ConsumerPayload", func() {
	Description("Consumer Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("firstname", String, "Consumer firstname", func() {
		Metadata("struct:tag:datastore", "firstname,noindex")
		Metadata("struct:tag:json", "firstname")
	})
	Attribute("lastname", String, "Consumer lastname", func() {
		Metadata("struct:tag:datastore", "lastname,noindex")
		Metadata("struct:tag:json", "lastname")
	})
	Attribute("active", Boolean, "Consumer active", func() {
		Metadata("struct:tag:datastore", "active,noindex")
		Metadata("struct:tag:json", "active")
	})
	Attribute("county", Integer, "Consumer county", func() {
		Metadata("struct:tag:datastore", "county,noindex")
		Metadata("struct:tag:json", "county")
	})
	Attribute("serviceCode", Integer, "Consumer serviceCode", func() {
		Metadata("struct:tag:datastore", "serviceCode,noindex")
		Metadata("struct:tag:json", "serviceCode")
	})
	Attribute("fundingSource", Integer, "Consumer fundingSource", func() {
		Metadata("struct:tag:datastore", "fundingSource,noindex")
		Metadata("struct:tag:json", "fundingSource")
	})
	Attribute("zip", String, "Consumer zip", func() {
		Metadata("struct:tag:datastore", "zip,noindex")
		Metadata("struct:tag:json", "zip")
	})
	Attribute("bsu", String, "Consumer bsu", func() {
		Metadata("struct:tag:datastore", "bsu,noindex")
		Metadata("struct:tag:json", "bsu")
	})
	Attribute("recipientID", String, "Consumer recipientID", func() {
		Metadata("struct:tag:datastore", "recipientID,noindex")
		Metadata("struct:tag:json", "recipientID")
	})
	Attribute("dia", Integer, "Consumer dia", func() {
		Metadata("struct:tag:datastore", "dia,noindex")
		Metadata("struct:tag:json", "dia")
	})
	Attribute("units", Number, "Units units", func() {
		Metadata("struct:tag:datastore", "units,noindex")
		Metadata("struct:tag:json", "units")
	})
	Attribute("other", String, "Consumer other", func() {
		Metadata("struct:tag:datastore", "other,noindex")
		Metadata("struct:tag:json", "other")
	})

	Required("firstname", "lastname", "active", "county", "serviceCode", "fundingSource", "zip", "bsu", "recipientID", "dia", "units", "other")
})

var ConsumerQueryPayload = Type("ConsumerQueryPayload", func() {
	Description("Consumer Query Description.")

	Attribute("whereClause", String, "where clause", func() {
		Metadata("struct:tag:datastore", "whereClause,noindex")
		Metadata("struct:tag:json", "whereClause")
	})
})

var ConsumerItem = Type("consumerItem", func() {
	Reference(ConsumerPayload)

	Attribute("id")
	Attribute("firstname")
	Attribute("lastname")
	Attribute("active")
	Attribute("county")
	Attribute("serviceCode")
	Attribute("fundingSource")
	Attribute("zip")
	Attribute("bsu")
	Attribute("recipientID")
	Attribute("dia")
	Attribute("units")
	Attribute("other")

	Required("id", "firstname", "lastname", "active", "county", "serviceCode", "fundingSource", "zip", "bsu", "recipientID", "dia", "units", "other")

})

var ConsumerMedia = MediaType("application/consumerapi.consumerentity", func() {
	Description("Consumer response")
	TypeName("ConsumerMedia")
	ContentType("application/json")
	Reference(ConsumerPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("firstname")
		Attribute("lastname")
		Attribute("active")
		Attribute("county")
		Attribute("serviceCode")
		Attribute("fundingSource")
		Attribute("zip")
		Attribute("bsu")
		Attribute("recipientID")
		Attribute("dia")
		Attribute("units")
		Attribute("other")
		Attribute("consumers", ArrayOf("consumerItem"))
		Attribute("pager", Pager)

		Required("id", "firstname", "lastname", "active", "county", "serviceCode", "fundingSource", "zip", "bsu", "recipientID", "dia", "units", "other", "consumers", "pager")
	})

	View("default", func() {
		Attribute("id")
		Attribute("firstname")
		Attribute("lastname")
		Attribute("active")
		Attribute("county")
		Attribute("serviceCode")
		Attribute("fundingSource")
		Attribute("zip")
		Attribute("bsu")
		Attribute("recipientID")
		Attribute("dia")
		Attribute("units")
		Attribute("other")
	})

	View("paging", func() {
		Attribute("consumers")
		Attribute("pager")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new consumers.")
		Attribute("id")
	})
})
