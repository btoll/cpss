package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("BillSheet", func() {
	BasePath("/billsheet")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(BillSheetMedia)
	Description("Describes a billsheet.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new billsheet.")
		Payload(BillSheetPayload)
		Response(OK, func() {
			Status(200)
			Media(BillSheetMedia, "tiny")
		})
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", String, "BillSheet ID")
		})
		Description("Delete a billsheet by id.")
		Response(OK, func() {
			Status(200)
			Media(BillSheetMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all billsheets")
		Response(OK, CollectionOf(BillSheetMedia))
	})
})

var BillSheetPayload = Type("BillSheetPayload", func() {
	Description("BillSheet Description.")

	Attribute("id", String, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id,omitempty")
	})
	Attribute("recipientID", String, "recipientID", func() {
		Metadata("struct:tag:datastore", "recipientID,noindex")
		Metadata("struct:tag:json", "recipientID,omitempty")
	})
	Attribute("serviceDate", String, "BillSheet serviceDate", func() {
		Metadata("struct:tag:datastore", "serviceDate,noindex")
		Metadata("struct:tag:json", "serviceDate,omitempty")
	})
	Attribute("billedAmount", Number, "BillSheet billedAmount", func() {
		Metadata("struct:tag:datastore", "billedAmount,noindex")
		Metadata("struct:tag:json", "billedAmount,omitempty")
	})
	Attribute("consumer", String, "BillSheet consumer", func() {
		Metadata("struct:tag:datastore", "consumer,noindex")
		Metadata("struct:tag:json", "consumer,omitempty")
	})
	Attribute("status", String, "BillSheet status", func() {
		Metadata("struct:tag:datastore", "status,noindex")
		Metadata("struct:tag:json", "status,omitempty")
	})
	Attribute("confirmation", String, "BillSheet confirmation", func() {
		Metadata("struct:tag:datastore", "confirmation,noindex")
		Metadata("struct:tag:json", "confirmation,omitempty")
	})
	Attribute("service", String, "BillSheet service", func() {
		Metadata("struct:tag:datastore", "service,noindex")
		Metadata("struct:tag:json", "service,omitempty")
	})
	Attribute("county", String, "BillSheet county", func() {
		Metadata("struct:tag:datastore", "county,noindex")
		Metadata("struct:tag:json", "county,omitempty")
	})
	Attribute("specialist", String, "BillSheet specialist", func() {
		Metadata("struct:tag:datastore", "specialist,noindex")
		Metadata("struct:tag:json", "specialist,omitempty")
	})
	Attribute("recordNumber", String, "BillSheet recordNumber", func() {
		Metadata("struct:tag:datastore", "recordNumber,noindex")
		Metadata("struct:tag:json", "recordNumber,omitempty")
	})

	Required("recipientID", "serviceDate", "billedAmount", "consumer", "status", "confirmation", "service", "county", "specialist", "recordNumber")
})

var BillSheetMedia = MediaType("application/billsheetapi.billsheetentity", func() {
	Description("BillSheet response")
	TypeName("BillSheetMedia")
	ContentType("application/json")
	Reference(BillSheetPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("recipientID")
		Attribute("serviceDate")
		Attribute("billedAmount")
		Attribute("consumer")
		Attribute("status")
		Attribute("confirmation")
		Attribute("service")
		Attribute("county")
		Attribute("specialist")
		Attribute("recordNumber")

		Required("recipientID", "serviceDate", "billedAmount", "consumer", "status", "confirmation", "service", "county", "specialist", "recordNumber")
	})

	View("default", func() {
		Attribute("id")
		Attribute("recipientID")
		Attribute("serviceDate")
		Attribute("billedAmount")
		Attribute("consumer")
		Attribute("status")
		Attribute("confirmation")
		Attribute("service")
		Attribute("county")
		Attribute("specialist")
		Attribute("recordNumber")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new billsheets.")
		Attribute("id")
	})
})
