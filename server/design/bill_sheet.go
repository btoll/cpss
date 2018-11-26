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
		Response(OK, BillSheetMedia)
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
		Response(OK, ArrayOf("billSheetItem"))
	})

	Action("page", func() {
		Routing(POST("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of bill_sheets and a pager object")
		})
		Description("Get a page of bill_sheets that may be filtered")
		Payload(BillSheetQueryPayload)
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
	Attribute("specialist", Integer, "BillSheet specialist", func() {
		Metadata("struct:tag:datastore", "specialist,noindex")
		Metadata("struct:tag:json", "specialist")
	})
	Attribute("realSpecialist", Integer, "Analogous to linux' real user id", func() {
		Metadata("struct:tag:datastore", "realSpecialist,noindex")
		Metadata("struct:tag:json", "realSpecialist")
	})
	Attribute("consumer", Integer, "BillSheet consumer", func() {
		Metadata("struct:tag:datastore", "consumer,noindex")
		Metadata("struct:tag:json", "consumer")
	})
	Attribute("units", String, "Units units", func() {
		Metadata("struct:tag:datastore", "units,noindex")
		Metadata("struct:tag:json", "units")
	})
	Attribute("serviceDate", String, "BillSheet serviceDate", func() {
		Metadata("struct:tag:datastore", "serviceDate,noindex")
		Metadata("struct:tag:json", "serviceDate")
	})
	Attribute("formattedDate", String, "BillSheet formatted (%m/%d/%y) serviceDate", func() {
		Metadata("struct:tag:datastore", "formattedDate,noindex")
		Metadata("struct:tag:json", "formattedDate")
	})
	Attribute("serviceCode", Integer, "BillSheet serviceCode", func() {
		Metadata("struct:tag:datastore", "serviceCode,noindex")
		Metadata("struct:tag:json", "serviceCode")
	})
	Attribute("contractType", String, "BillSheet contractType", func() {
		Metadata("struct:tag:datastore", "contractType,noindex")
		Metadata("struct:tag:json", "contractType")
	})
	Attribute("status", Integer, "BillSheet status", func() {
		Metadata("struct:tag:datastore", "status,noindex")
		Metadata("struct:tag:json", "status")
	})
	Attribute("billedAmount", Number, "BillSheet billedAmount", func() {
		Metadata("struct:tag:datastore", "billedAmount,noindex")
		Metadata("struct:tag:json", "billedAmount")
	})
	Attribute("confirmation", String, "BillSheet confirmation", func() {
		Metadata("struct:tag:datastore", "confirmation,noindex")
		Metadata("struct:tag:json", "confirmation")
	})
	Attribute("description", String, "BillSheet description", func() {
		Metadata("struct:tag:datastore", "description,noindex")
		Metadata("struct:tag:json", "description")
	})

	Required("specialist", "consumer", "serviceDate", "serviceCode")
})

var BillSheetQueryPayload = Type("BillSheetQueryPayload", func() {
	Description("BillSheet Query Description.")

	Attribute("whereClause", String, "where clause", func() {
		Metadata("struct:tag:datastore", "whereClause,noindex")
		Metadata("struct:tag:json", "whereClause")
	})
})

var BillSheetItem = Type("billSheetItem", func() {
	Reference(BillSheetPayload)

	Attribute("id")
	Attribute("specialist")
	Attribute("consumer")
	Attribute("units")
	Attribute("serviceDate")
	Attribute("formattedDate")
	Attribute("formattedDate")
	Attribute("serviceCode")
	Attribute("contractType")
	Attribute("status")
	Attribute("billedAmount")
	Attribute("confirmation")
	Attribute("description")

	Required("id", "specialist", "consumer", "serviceDate", "serviceCode")
})

var BillSheetMedia = MediaType("application/billsheetapi.billsheetentity", func() {
	Description("BillSheet response")
	TypeName("BillSheetMedia")
	ContentType("application/json")
	Reference(BillSheetPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("specialist")
		Attribute("consumer")
		Attribute("units")
		Attribute("serviceDate")
		Attribute("formattedDate")
		Attribute("serviceCode")
		Attribute("contractType")
		Attribute("status")
		Attribute("billedAmount")
		Attribute("confirmation")
		Attribute("description")
		Attribute("billsheets", ArrayOf("billSheetItem"))
		Attribute("pager", Pager)

		Required("id", "specialist", "consumer", "serviceDate", "serviceCode")
	})

	View("default", func() {
		Attribute("id")
		Attribute("specialist")
		Attribute("consumer")
		Attribute("units")
		Attribute("serviceDate")
		Attribute("formattedDate")
		Attribute("serviceCode")
		Attribute("contractType")
		Attribute("status")
		Attribute("billedAmount")
		Attribute("confirmation")
		Attribute("description")
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
