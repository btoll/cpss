package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("TimeEntry", func() {
	BasePath("/timeentry")
	// Seems that goa doesn't like setting DefaultMedia here at the top-level when the MediaType has multiple Views.
	//	DefaultMedia(TimeEntryMedia)
	Description("Describes a timeentry.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new timeentry.")
		Payload(TimeEntryPayload)
		Response(OK, func() {
			Status(200)
			Media(TimeEntryMedia, "tiny")
		})
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(TimeEntryPayload)
		Params(func() {
			Param("id", Integer, "TimeEntry ID")
		})
		Description("Update a timeentry by id.")
		Response(OK, TimeEntryMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "TimeEntry ID")
		})
		Description("Delete a timeentry by id.")
		Response(OK, func() {
			Status(200)
			Media(TimeEntryMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all time entries")
		Response(OK, CollectionOf(TimeEntryMedia))
	})

	Action("page", func() {
		Routing(GET("/list/:page"))
		Params(func() {
			Param("page", Integer, "Given a page number, returns an object consisting of the slice of time entries and a pager object")
		})
		Description("Get a page of time entries")
		Response(OK, func() {
			Status(200)
			Media(TimeEntryMedia, "paging")
		})
	})
})

var TimeEntryPayload = Type("TimeEntryPayload", func() {
	Description("TimeEntry Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("specialist", Integer, "TimeEntry specialist", func() {
		Metadata("struct:tag:datastore", "specialist,noindex")
		Metadata("struct:tag:json", "specialist")
	})
	Attribute("consumer", Integer, "TimeEntry consumer", func() {
		Metadata("struct:tag:datastore", "consumer,noindex")
		Metadata("struct:tag:json", "consumer")
	})
	Attribute("serviceDate", String, "TimeEntry serviceDate", func() {
		Metadata("struct:tag:datastore", "serviceDate,noindex")
		Metadata("struct:tag:json", "serviceDate")
	})
	Attribute("serviceCode", Integer, "TimeEntry serviceCode", func() {
		Metadata("struct:tag:datastore", "serviceCode,noindex")
		Metadata("struct:tag:json", "serviceCode")
	})
	Attribute("hours", Number, "TimeEntry hours", func() {
		Metadata("struct:tag:datastore", "hours,noindex")
		Metadata("struct:tag:json", "hours")
	})
	Attribute("description", String, "TimeEntry description", func() {
		Metadata("struct:tag:datastore", "description,noindex")
		Metadata("struct:tag:json", "description")
	})
	Attribute("county", Integer, "TimeEntry county", func() {
		Metadata("struct:tag:datastore", "county,noindex")
		Metadata("struct:tag:json", "county")
	})
	Attribute("contractType", String, "TimeEntry contractType", func() {
		Metadata("struct:tag:datastore", "contractType,noindex")
		Metadata("struct:tag:json", "contractType")
	})
	Attribute("billingCode", String, "TimeEntry billingCode", func() {
		Metadata("struct:tag:datastore", "billingCode,noindex")
		Metadata("struct:tag:json", "billingCode")
	})

	Required("specialist", "consumer", "serviceDate", "serviceCode", "hours", "description", "county", "contractType", "billingCode")
})

var TimeEntryItem = Type("timeEntryItem", func() {
	Reference(TimeEntryPayload)

	Attribute("id")
	Attribute("specialist")
	Attribute("consumer")
	Attribute("serviceDate")
	Attribute("serviceCode")
	Attribute("hours")
	Attribute("description")
	Attribute("county")
	Attribute("contractType")
	Attribute("billingCode")

	Required("id", "specialist", "consumer", "serviceDate", "serviceCode", "hours", "description", "county", "contractType", "billingCode")
})

var TimeEntryMedia = MediaType("application/timeentryapi.timeentryentity", func() {
	Description("TimeEntry response")
	TypeName("TimeEntryMedia")
	ContentType("application/json")
	Reference(TimeEntryPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("specialist")
		Attribute("consumer")
		Attribute("serviceDate")
		Attribute("serviceCode")
		Attribute("hours")
		Attribute("description")
		Attribute("county")
		Attribute("contractType")
		Attribute("billingCode")
		Attribute("timeEntries", ArrayOf("timeEntryItem"))
		Attribute("pager", Pager)

		Required("id", "specialist", "consumer", "serviceDate", "serviceCode", "hours", "description", "county", "contractType", "billingCode")
	})

	View("default", func() {
		Attribute("id")
		Attribute("specialist")
		Attribute("consumer")
		Attribute("serviceDate")
		Attribute("serviceCode")
		Attribute("hours")
		Attribute("description")
		Attribute("county")
		Attribute("contractType")
		Attribute("billingCode")
	})

	View("paging", func() {
		Attribute("timeEntries")
		Attribute("pager")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new time entries.")
		Attribute("id")
	})
})
