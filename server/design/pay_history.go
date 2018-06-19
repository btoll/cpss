package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("PayHistory", func() {
	BasePath("/payhistory")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(PayHistoryMedia)
	Description("Describes a pay history.")

	Action("show", func() {
		Routing(GET("/:id"))
		Description("Get all pay history by specialist")
		Response(OK, CollectionOf(PayHistoryMedia))
	})

	/*
		Action("page", func() {
			Routing(POST("/list/:page"))
			Params(func() {
				Param("page", Integer, "Given a page number, returns an object consisting of the slice of pay histories and a pager object")
			})
			Description("Get a page of pay histories that may be filtered")
			Payload(PayHistoryQueryPayload)
			Response(OK, func() {
				Status(200)
				Media(PayHistoryMedia, "paging")
			})
		})
	*/
})

var PayHistoryPayload = Type("PayHistoryPayload", func() {
	Description("PayHistory Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("specialist", Integer, "PayHistory specialist", func() {
		Metadata("struct:tag:datastore", "specialist,noindex")
		Metadata("struct:tag:json", "specialist")
	})
	Attribute("changeDate", String, "PayHistory change date", func() {
		Metadata("struct:tag:datastore", "changeDate,noindex")
		Metadata("struct:tag:json", "changeDate")
	})
	Attribute("payrate", Number, "PayHistory payrate", func() {
		Metadata("struct:tag:datastore", "payrate,noindex")
		Metadata("struct:tag:json", "payrate")
	})

	Required("specialist", "changeDate", "payrate")
})

/*
var PayHistoryItem = Type("payhistoryItem", func() {
	Reference(PayHistoryPayload)

	Attribute("id")
	Attribute("specialist")
	Attribute("changeDate")
	Attribute("payrate")

	Required("specialist", "changeDate", "payrate")
})
*/

var PayHistoryMedia = MediaType("application/payhistoryapi.payhistoryentity", func() {
	Description("PayHistory response")
	TypeName("PayHistoryMedia")
	ContentType("application/json")
	Reference(PayHistoryPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("specialist")
		Attribute("changeDate")
		Attribute("payrate")

		Required("specialist", "changeDate", "payrate")
	})

	View("default", func() {
		Attribute("id")
		Attribute("specialist")
		Attribute("changeDate")
		Attribute("payrate")
	})

	//	View("paging", func() {
	//		Attribute("payhistory")
	//		Attribute("pager")
	//	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new pay history.")
		Attribute("id")
	})
})
