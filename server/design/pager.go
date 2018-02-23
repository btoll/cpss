package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var Pager = Type("pager", func() {
	Attribute("currentPage", Integer)
	Attribute("recordsPerPage", Integer)
	Attribute("totalCount", Integer)
	Attribute("totalPages", Integer)

	Required("currentPage", "recordsPerPage", "totalCount", "totalPages")
})
