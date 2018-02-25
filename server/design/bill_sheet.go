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

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(BillSheetPayload)
		Params(func() {
			Param("id", Integer, "BillSheet ID")
		})
		Description("Update a billsheet by id.")
		Response(OK, BillSheetMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "BillSheet ID")
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

	Action("page", func() {
		Routing(GET("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of bill_sheets and a pager object")
		})
		Description("Get a page of bill_sheets")
		Response(OK, func() {
			Status(200)
			Media(BillSheetMedia, "paging")
		})
	})
})

var BillSheetPayload = Type("BillSheetPayload", func() {
	Description("BillSheet Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("recipientID", String, "recipientID", func() {
		Metadata("struct:tag:datastore", "recipientID,noindex")
		Metadata("struct:tag:json", "recipientID")
	})
	Attribute("serviceDate", String, "BillSheet serviceDate", func() {
		Metadata("struct:tag:datastore", "serviceDate,noindex")
		Metadata("struct:tag:json", "serviceDate")
	})
	Attribute("billedAmount", Number, "BillSheet billedAmount", func() {
		Metadata("struct:tag:datastore", "billedAmount,noindex")
		Metadata("struct:tag:json", "billedAmount")
	})
	Attribute("consumer", Integer, "BillSheet consumer", func() {
		Metadata("struct:tag:datastore", "consumer,noindex")
		Metadata("struct:tag:json", "consumer")
	})
	Attribute("status", Integer, "BillSheet status", func() {
		Metadata("struct:tag:datastore", "status,noindex")
		Metadata("struct:tag:json", "status")
	})
	Attribute("confirmation", String, "BillSheet confirmation", func() {
		Metadata("struct:tag:datastore", "confirmation,noindex")
		Metadata("struct:tag:json", "confirmation")
	})
	Attribute("service", Integer, "BillSheet service", func() {
		Metadata("struct:tag:datastore", "service,noindex")
		Metadata("struct:tag:json", "service")
	})
	Attribute("county", Integer, "BillSheet county", func() {
		Metadata("struct:tag:datastore", "county,noindex")
		Metadata("struct:tag:json", "county")
	})
	Attribute("specialist", Integer, "BillSheet specialist", func() {
		Metadata("struct:tag:datastore", "specialist,noindex")
		Metadata("struct:tag:json", "specialist")
	})
	Attribute("recordNumber", String, "BillSheet recordNumber", func() {
		Metadata("struct:tag:datastore", "recordNumber,noindex")
		Metadata("struct:tag:json", "recordNumber")
	})

	Required("recipientID", "serviceDate", "billedAmount", "consumer", "status", "confirmation", "service", "county", "specialist", "recordNumber")
})

var BillSheetItem = Type("billSheetItem", func() {
	Reference(BillSheetPayload)

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

	Required("id", "recipientID", "serviceDate", "billedAmount", "consumer", "status", "confirmation", "service", "county", "specialist", "recordNumber")
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
		Attribute("billsheets", ArrayOf("billSheetItem"))
		Attribute("pager", Pager)

		Required("id", "recipientID", "serviceDate", "billedAmount", "consumer", "status", "confirmation", "service", "county", "specialist", "recordNumber", "billsheets", "pager")
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

	View("paging", func() {
		Attribute("billsheets")
		Attribute("pager")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new billsheets.")
		Attribute("id")
	})
})
