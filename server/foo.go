package main

import (
	"strconv"

	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
)

// FooController implements the Foo resource.
type FooController struct {
	*goa.Controller
}

// NewFooController creates a Foo controller.
func NewFooController(service *goa.Service) *FooController {
	return &FooController{Controller: service.NewController("FooController")}
}

func fakeData() app.FooMediaCollection {
	data := []string{
		"Ben Toll",
		"Ginger Toll",
		"Fred Moseley",
		"Trey Nelson",
	}
	res := make(app.FooMediaCollection, len(data))
	for i, name := range data {
		res[i] = &app.FooMedia{strconv.Itoa(i), name}
	}
	return res
}

// List runs the list action.
func (c *FooController) List(ctx *app.ListFooContext) error {
	// FooController_List: start_implement

	return ctx.OK(fakeData())

	// FooController_List: end_implement
}
