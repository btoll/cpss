package design

import (
	//	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = API("cpss", func() {
	Title("Central Pennsylvania Support Services")
	Description("api for mobile & web clients")
	Host("localhost:8080")
	Scheme("http")
	BasePath("/cpss")
	TermsOfService("cpss tos")
	//	License(func() { // API Licensing information
	//		Name("Private (no license offered)")
	//		URL("http://google.com")
	//	})
	//	Docs(func() {
	//		Description("doc description")
	//		URL("http://google.com")
	//	})

	// Add CORS
	// https://github.com/goadesign/goa-cellar/commit/1ce01fda44482340624ef907b4f40b124a3f59c3
	Origin("*", func() {
		Methods("GET", "POST", "PUT", "DELETE")
		Headers("Accept, Accept-Language, Content-Language, Content-Type")
		MaxAge(600)
		Credentials()
	})
})
