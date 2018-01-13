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
		Description("Create a new sport.")
		Payload(ConsumerPayload)
		Response(OK, func() {
			Status(200)
			Media(ConsumerMedia, "tiny")
		})
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", String, "Consumer ID")
		})
		Description("Delete a consumer by id.")
		Response(OK, func() {
			Status(200)
		})
		Response(NoContent)
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all consumers")
		Response(OK, CollectionOf(ConsumerMedia))
	})
})

var ConsumerPayload = Type("ConsumerPayload", func() {
	Description("Consumer Description.")

	Attribute("id", String, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id,omitempty")
	})
	Attribute("firstname", String, "Consumer firstname", func() {
		Metadata("struct:tag:datastore", "firstname,noindex")
		Metadata("struct:tag:json", "firstname,omitempty")
	})
	Attribute("lastname", String, "Consumer lastname", func() {
		Metadata("struct:tag:datastore", "lastname,noindex")
		Metadata("struct:tag:json", "lastname,omitempty")
	})
	Attribute("active", Boolean, "Consumer active", func() {
		Metadata("struct:tag:datastore", "active,noindex")
		Metadata("struct:tag:json", "active,omitempty")
	})
	Attribute("countyName", String, "Consumer countyName", func() {
		Metadata("struct:tag:datastore", "countyName,noindex")
		Metadata("struct:tag:json", "countyName,omitempty")
	})
	Attribute("countyCode", String, "Consumer countyCode", func() {
		Metadata("struct:tag:datastore", "countyCode,noindex")
		Metadata("struct:tag:json", "countyCode,omitempty")
	})
	Attribute("fundingSource", String, "Consumer fundingSource", func() {
		Metadata("struct:tag:datastore", "fundingSource,noindex")
		Metadata("struct:tag:json", "fundingSource,omitempty")
	})
	Attribute("zip", String, "Consumer zip", func() {
		Metadata("struct:tag:datastore", "zip,noindex")
		Metadata("struct:tag:json", "zip,omitempty")
	})
	Attribute("bsu", String, "Consumer bsu", func() {
		Metadata("struct:tag:datastore", "bsu,noindex")
		Metadata("struct:tag:json", "bsu,omitempty")
	})
	Attribute("recipientID", String, "Consumer recipientID", func() {
		Metadata("struct:tag:datastore", "recipientID,noindex")
		Metadata("struct:tag:json", "recipientID,omitempty")
	})
	Attribute("diaCode", String, "Consumer diaCode", func() {
		Metadata("struct:tag:datastore", "diaCode,noindex")
		Metadata("struct:tag:json", "diaCode,omitempty")
	})
	Attribute("consumerID", String, "Consumer consumerID", func() {
		Metadata("struct:tag:datastore", "consumerID,noindex")
		Metadata("struct:tag:json", "consumerID,omitempty")
	})
	Attribute("copay", Number, "Consumer copay", func() {
		Metadata("struct:tag:datastore", "copay,noindex")
		Metadata("struct:tag:json", "copay,omitempty")
	})
	Attribute("dischargeDate", String, "Consumer dischargeDate", func() {
		Metadata("struct:tag:datastore", "dischargeDate,noindex")
		Metadata("struct:tag:json", "dischargeDate,omitempty")
	})
	Attribute("other", String, "Consumer other", func() {
		Metadata("struct:tag:datastore", "other,noindex")
		Metadata("struct:tag:json", "other,omitempty")
	})

	Required("firstname", "lastname", "active", "countyName", "countyCode", "fundingSource", "zip", "bsu", "recipientID", "diaCode", "consumerID", "copay", "dischargeDate", "other")
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
		Attribute("countyName")
		Attribute("countyCode")
		Attribute("fundingSource")
		Attribute("zip")
		Attribute("bsu")
		Attribute("recipientID")
		Attribute("diaCode")
		Attribute("consumerID")
		Attribute("copay")
		Attribute("dischargeDate")
		Attribute("other")

		Required("id", "firstname", "lastname", "active", "countyName", "countyCode", "fundingSource", "zip", "bsu", "recipientID", "diaCode", "consumerID", "copay", "dischargeDate", "other")
	})

	View("default", func() {
		Attribute("id")
		Attribute("firstname")
		Attribute("lastname")
		Attribute("active")
		Attribute("countyName")
		Attribute("countyCode")
		Attribute("fundingSource")
		Attribute("zip")
		Attribute("bsu")
		Attribute("recipientID")
		Attribute("diaCode")
		Attribute("consumerID")
		Attribute("copay")
		Attribute("dischargeDate")
		Attribute("other")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new consumers.")
		Attribute("id")
	})
})
